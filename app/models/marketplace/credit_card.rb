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

  scope :default, ->{ where(default: true) }
  scope :authorized, ->{ where.not(gateway_customer_reference: nil) }

  delegate :name,
           to: :pharmacy, prefix: true


  attr_accessor :encrypted_card

  validates :email, email: true

  after_save :handle_default_card!

  def authorize!(options = {})
    authorization_response = PAYMENT_GATEWAY.authorize({
      token: options.fetch(:token),
      user: options.fetch(:order).user
    })

    if authorization_response.authorized?
      self.number = authorization_response.card_digits
      self.brand = authorization_response.card_brand
      self.expiry_month = authorization_response.card_exp_month
      self.expiry_year = authorization_response.card_exp_year
      self.gateway_customer_reference = authorization_response.customer_reference
      self.default = true
      self.save!
    else
      raise Marketplace::Errors::PaymentError, "Card payment not authorized"
    end
  end

  def take_payment!(options = {})
    self.authorize!(options) unless gateway_customer_reference
    self.payments.create!({
      order: options.fetch(:order),
      currency_code: options.fetch(:currency_code, "EUR"),
      amount_cents: options.fetch(:amount_cents)
    }).tap do |payment|
      purchase_response = PAYMENT_GATEWAY.purchase({ amount_currency: payment.currency_code,
                                                     amount_value: payment.amount_cents,
                                                     customer: self.gateway_customer_reference,
                                                     email: self.email })
      if purchase_response.authorized?
        payment.gateway_reference = purchase_response.reference
        payment.result_code       = purchase_response.result_code
        payment.gateway_response  = purchase_response.json_response
        payment.save!
      else
        raise Marketplace::Errors::PaymentError, "Card payment not authorized"
      end
    end
  end

  def card_type
    case brand
    when 'MasterCard'
      'mastercard'
    else
      'visa'
    end
  end

  private

  def handle_default_card!
    if saved_change_to_default? && default
      pharmacy.credit_cards.where("id != ?", id).update_all(default: false)
    end
  end
end
