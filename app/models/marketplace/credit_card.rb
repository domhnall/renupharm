class Marketplace::CreditCard < ApplicationRecord
  include EmailValidatable

  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :credit_cards

  has_many :payments,
    class_name: "Marketplace::Payment",
    foreign_key: :marketplace_credit_card_id,
    inverse_of: :credit_card

  delegate :name,
           to: :pharmacy, prefix: true


  attr_accessor :encrypted_card

  validates :email, email: true

  def authorize!(options = {})
    self.payments.create!({
      currency_code: options.fetch(:currency_code, "EUR"),
      amount_cents: options.fetch(:amount_cents, 1)
    }).tap do |payment|
      request = Adyen::InitialPurchaseRequest.new({ amount_currency: payment.currency_code,
                                                    amount_value: payment.amount_cents,
                                                    reference: payment.renupharm_reference ,
                                                    shopper_reference: shopper_reference,
                                                    shopper_email: self.email,
                                                    shopper_ip: options.fetch(:shopper_ip, nil),
                                                    encrypted_card: self.encrypted_card,
                                                    merchant_account: PAYMENT_GATEWAY.merchant_account })

      purchase_response = PAYMENT_GATEWAY.purchase(request)

      if purchase_response.authorised?
        payment.gateway_reference = purchase_response.psp_reference
        payment.result_code       = purchase_response.result_code
        payment.auth_code         = purchase_response.auth_code
        payment.save!
      else
        raise Marketplace::Errors::PaymentError, "Card payment not authorized"
      end
    end
  end

  def take_payment!(options = {})
    populate_recurring_detail_reference unless recurring_detail_reference
    self.payments.create!({
      order: options.fetch(:order),
      currency_code: options.fetch(:currency_code, "EUR"),
      amount_cents: options.fetch(:amount_cents)
    }).tap do |payment|
      purchase_request = Adyen::RecurringPurchaseRequest.new({ selected_recurring_detail_reference: self.recurring_detail_reference,
                                                               amount_currency: payment.currency_code,
                                                               amount_value: payment.amount_cents,
                                                               reference: payment.renupharm_reference,
                                                               shopper_reference: shopper_reference,
                                                               shopper_email: self.email,
                                                               shopper_ip: options.fetch(:shopper_ip, nil),
                                                               merchant_account: PAYMENT_GATEWAY.merchant_account })
      purchase_response = PAYMENT_GATEWAY.purchase_subscription(purchase_request)

      if purchase_response.authorised?
        payment.gateway_reference = purchase_response.psp_reference
        payment.result_code       = purchase_response.result_code
        payment.auth_code         = purchase_response.auth_code
        payment.save!
      end
    end
  end

  def shopper_reference
    "#{id}-#{created_at.to_i}"
  end

  def card_type
    case brand
    when 'mc'
      'mastercard'
    else
      'visa'
    end
  end

  private

  def populate_recurring_detail_reference
    PAYMENT_GATEWAY.list_recurring(Adyen::ListRecurringRequest.new({
      merchant_account: PAYMENT_GATEWAY.merchant_account,
      shopper_reference: self.shopper_reference,
      shopper_email: self.email
    })).details.first.tap do |detail|
      self.recurring_detail_reference = detail.recurring_detail_reference
      self.brand                      = detail.variant
      self.holder_name                = detail.card_holder_name
      self.expiry_month               = detail.card_expiry_month
      self.expiry_year                = detail.card_expiry_year
      self.number                     = detail.card_number
      self.save!
    end
  end
end
