class Marketplace::CreditCard < ApplicationRecord
  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :credit_cards

  delegate :name,
           to: :pharmacy, prefix: true

  before_save :set_tx_reference

  attr_accessor :encrypted_card, :shopper_ip

  def authorize!(options = {})
    byebug
    request = Adyen::InitialPurchaseRequest.new({ amount_currency: "EUR",
                                                  amount_value: 1,
                                                  reference: self.tx_reference ,
                                                  shopper_reference: shopper_reference,
                                                  shopper_email: self.email,
                                                  shopper_ip: self.shopper_ip,
                                                  encrypted_card: self.encrypted_card,
                                                  merchant_account: PAYMENT_GATEWAY.merchant_account })

    purchase_response = PAYMENT_GATEWAY.purchase(request)

    if purchase_response.authorised?
      #self.psp_reference = purchase_response.psp_reference
      #self.result_code = purchase_response.result_code
      #self.auth_code = purchase_response.auth_code
      self.save

      return :success
    end
  end

  def shopper_reference
    "#{id}-#{created_at.to_i}"
  end

  private

  def set_tx_reference
    self.tx_reference ||= SecureRandom.uuid
  end
end
