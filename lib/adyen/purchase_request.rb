module Adyen
  class PurchaseRequest
    REQUEST_ATTRIBUTES = [ :action,
                           :amount_currency,
                           :amount_value,
                           :merchant_account,
                           :reference,
                           :recurring_contract,
                           :shopper_reference,
                           :shopper_email,
                           :shopper_ip ].freeze

    ADYEN_REQUEST_KEYS = { action: 'action',
                           amount_currency: 'paymentRequest.amount.currency',
                           amount_value: 'paymentRequest.amount.value',
                           merchant_account: 'paymentRequest.merchantAccount',
                           reference: 'paymentRequest.reference',
                           recurring_contract: 'paymentRequest.recurring.contract',
                           shopper_reference: 'paymentRequest.shopperReference',
                           shopper_email: 'paymentRequest.shopperEmail',
                           shopper_ip: 'paymentRequest.shopperIP' }.freeze

    attr_accessor *REQUEST_ATTRIBUTES

    def initialize(params = {})
     @action             = params.fetch(:action, 'Payment.authorise')
     @amount_currency    = params.fetch(:amount_currency, nil)
     @amount_value       = params.fetch(:amount_value, nil)
     @merchant_account   = params.fetch(:merchant_account, nil)
     @reference          = params.fetch(:reference, nil)
     @recurring_contract = params.fetch(:recurring_contract, 'RECURRING')
     @shopper_reference  = params.fetch(:shopper_reference, nil)
     @shopper_email      = params.fetch(:shopper_email, nil)
     @shopper_ip         = params.fetch(:shopper_ip, nil)
    end

    def build_adyen_params
      raise Adyen::Error::ApiRequest, "Cannot build valid request from parameters supplied." unless valid?
      REQUEST_ATTRIBUTES.inject({}){ |memo, attr| memo[ADYEN_REQUEST_KEYS[attr]] = self.send(attr) if self.send(attr); memo }
    end

    def valid?
      self.action &&
      self.amount_currency &&
      self.amount_value &&
      self.merchant_account &&
      self.reference &&
      self.shopper_reference
    end

  end
end
