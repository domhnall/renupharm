module Adyen
  class ListRecurringRequest
    REQUEST_ATTRIBUTES = [ :action,
                           :recurring_contract,
                           :merchant_account,
                           :shopper_reference,
                           :shopper_email ].freeze

    ADYEN_REQUEST_KEYS = { action: 'action',
                           recurring_contract: 'recurringDetailsRequest.recurring.contract',
                           merchant_account: 'recurringDetailsRequest.merchantAccount',
                           shopper_reference: 'recurringDetailsRequest.shopperReference',
                           shopper_email: 'recurringDetailsRequest.shopperEmail' }.freeze

    attr_accessor *REQUEST_ATTRIBUTES

    def initialize(params = {})
     @action             = params.fetch(:action, 'Recurring.listRecurringDetails')
     @recurring_contract = params.fetch(:recurring_contract, 'RECURRING')
     @merchant_account   = params.fetch(:merchant_account, nil)
     @shopper_reference  = params.fetch(:shopper_reference, nil)
     @shopper_email      = params.fetch(:shopper_email, nil)
    end

    def build_adyen_params
      raise Adyen::Error::ApiRequest, "Cannot build valid request from parameters supplied." unless valid?
      REQUEST_ATTRIBUTES.inject({}){ |memo, attr| memo[ADYEN_REQUEST_KEYS[attr]] = self.send(attr) if self.send(attr); memo }
    end

    def valid?
      self.action &&
      self.recurring_contract &&
      self.merchant_account &&
      self.shopper_reference
    end
  end
end
