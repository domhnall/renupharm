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


  attr_accessor :encrypted_card, :shopper_ip

  validates :email, email: true

  def authorize!(options = {})
    self.payments.create({
      currency_code: options.fetch(:currency_code, "EUR"),
      amount_cents: options.fetch(:amount_cents, 1)
    }).tap do |payment|
      request = Adyen::InitialPurchaseRequest.new({ amount_currency: payment.currency_code,
                                                    amount_value: payment.amount_cents,
                                                    reference: payment.renupharm_reference ,
                                                    shopper_reference: shopper_reference,
                                                    shopper_email: self.email,
                                                    shopper_ip: self.shopper_ip,
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

  def shopper_reference
    "#{id}-#{created_at.to_i}"
  end
end
