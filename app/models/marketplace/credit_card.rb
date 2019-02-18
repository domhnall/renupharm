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
      self.gateway_customer_reference = authorization_response.customer_reference
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

  def handle_default_card!
    if saved_change_to_default? && default
      pharmacy.credit_cards.where("id != ?", id).update_all(default: false)
    end
  end
end
