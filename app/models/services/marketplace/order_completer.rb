class Services::Marketplace::OrderCompleter
  include Rails.application.routes.url_helpers

  attr_reader :order, :token, :email, :customer_reference

  def initialize(order: nil, token: nil, email: nil, customer_reference: nil)
    raise ArgumentError, "Must supply order" unless order
    raise ArgumentError, "Must supply :token or :customer_reference" unless (token || customer_reference)
    raise ArgumentError, "Must supply email if creating a new payment method" unless (email || customer_reference)
    @order = order
    @token = token
    @email = email
    @customer_reference = customer_reference
    @errors = []
    @response = Services::Response.new(errors: @errors)
  end

  def call
    validate_listing_available
    take_payment
    remove_listing
    calculate_fees
    send_emails
    contact_courier
    @response
  rescue Services::Error => e
    @errors << e
    @response
  rescue Exception => e
    Admin::ErrorMailer.payment_error(
      order_id: order.id,
      message: e.message,
      backtrace: e.backtrace
    ).deliver_later
    raise Services::Error, I18n.t("general.error")
  end

  private

  def validate_listing_available
    if order.listings.active_listings.count != order.listings.count
      raise Services::Error, I18n.t("marketplace.cart.errors.listing_unavailable")
    end
  end

  def take_payment
    credit_card.take_payment!({
      order: order,
      currency_code: order.currency_code,
      amount_cents: order.price_cents,
      token: token
    })
  rescue Exception => e
    Admin::ErrorMailer.payment_error(
      order_id: order.id,
      message: e.message,
      backtrace: e.backtrace
    ).deliver_later
    raise Services::Error, I18n.t("marketplace.cart.errors.failed_payment")
  end

  def credit_card
    @_credit_card ||= if customer_reference.present?
      buying_pharmacy.credit_cards.authorized.find_by_gateway_customer_reference(customer_reference)
    else
      buying_pharmacy.credit_cards.create(email: email)
    end
  end

  def remove_listing
    order.line_items.each do |line_item|
      listing = line_item.listing
      listing.purchased_at = Time.now
      listing.save!

      (listing.line_items - [line_item]).each(&:destroy)
    end
  end

  def calculate_fees
    [ Marketplace::Accounts::SellerFee,
      Marketplace::Accounts::CourierFee,
      Marketplace::Accounts::PaymentGatewayFee,
      Marketplace::Accounts::ResidualFee ].each do |calculator|
      calculator.new(payment: order.payment).calculate!
    end
  end

  def send_emails
    buying_pharmacy.agents.active.each do |agent|
      Marketplace::OrderMailer.purchase_notification(agent_id: agent.id, order_id: order.id).deliver_later
    end
    selling_pharmacy.agents.active.each do |agent|
      Marketplace::OrderMailer.sale_notification(agent_id: agent.id, order_id: order.id).deliver_later
    end
  end

  def contact_courier
    # No-op
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
