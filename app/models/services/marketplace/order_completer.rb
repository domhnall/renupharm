class Services::Marketplace::OrderCompleter
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
    raise Services::Error, "Must have a default credit card set up for pharmacy." if order.pharmacy.credit_cards.empty?
  end

  def take_payment
    credit_card.take_payment!(amount_cents: @order.price_cents, shopper_ip: @shopper_ip)
  rescue Exception => e
    #send_support_email
    raise Services::Error, "There was a error taking payment, please contact support."
  end

  def remove_listing
    order.line_items.map(&:listing).each do |listing|
      listing.purchased_at = Time.now
      listing.save!
    end
  end

  def send_emails
    byebug
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
    @_seller ||= listing.pharmacy
  end
end
