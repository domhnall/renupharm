module Adyen
  class InitialPurchaseRequest < PurchaseRequest
    ADYEN_REQUEST_KEYS = { encrypted_card: 'paymentRequest.additionalData.card.encrypted.json' }.freeze

    attr_accessor :encrypted_card

    def initialize(params = {})
      super(params)
      @encrypted_card     = params.fetch(:encrypted_card, nil)
    end

    def build_adyen_params
      raise Adyen::Error::ApiRequest, "Cannot build valid request from parameters supplied." unless valid?
      super.merge({ ADYEN_REQUEST_KEYS[:encrypted_card] => self.encrypted_card })
    end

    def valid?
      super && !self.encrypted_card.blank?
    end
  end
end
