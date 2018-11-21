class Services::Marketplace::OrderCompleter
  include Rails.application.routes.url_helpers

  attr_reader :order

  def initialize(order: order, shopper_ip: shopper_ip)
    @order = order
    @shopper_ip = shopper_ip
    @errors = []
    @response = Services::Response.new(errors: @errors)
  end

  def call
    validate_card_present
    take_payment
    remove_listing
    send_emails
    contact_courier
    @response
  rescue Services::Error => e
    @errors << e
    @response
  end

  private

  def validate_card_present
    if order.pharmacy.credit_cards.empty?
      raise Services::Error, I18n.t("marketplace.cart.errors.no_credit_card", url: marketplace_pharmacy_path(order.pharmacy) + "#pharmacy_credit_cards")
    end
  end

  def take_payment
    credit_card.take_payment!({
      order: @order,
      amount_cents: @order.price_cents,
      shopper_ip: @shopper_ip
    })
  rescue Exception => e
    #send_support_email
    raise Services::Error, I18n.t("marketplace.cart.errors.failed_payment")
  end

  def remove_listing
    order.line_items.map(&:listing).each do |listing|
      listing.purchased_at = Time.now
      listing.save!
    end
  end

  def send_emails
    buying_pharmacy.agents.active.each do |agent|
      Marketplace::OrderMailer.purchase_notification(agent_id: agent.id, order_id: @order.id).deliver_later
    end
    selling_pharmacy.agents.active.each do |agent|
      Marketplace::OrderMailer.sale_notification(agent_id: agent.id, order_id: @order.id).deliver_later
    end
  end

  def contact_courier
    # No-op
  end

  def credit_card
    buying_pharmacy.credit_cards.first
  end

  def listing
    @_listing ||= order.line_items.first.listing
  end

  def buying_pharmacy
    @_buyer ||= order.pharmacy
  end

  def selling_pharmacy
    @_seller ||= listing.selling_pharmacy
  end
end
