#
# If a "recurring_detail_reference" is provided then only that detail will be disbled.
# Otherwise ALL recurring details will be disabled for that shopper_reference.
#
module Adyen
  class DisableRecurringRequest
    REQUEST_ATTRIBUTES = [ :action,
                           :merchant_account,
                           :shopper_reference,
                           :recurring_detail_reference ].freeze

    ADYEN_REQUEST_KEYS = { action: 'action',
                           merchant_account: 'disableRequest.merchantAccount',
                           shopper_reference: 'disableRequest.shopperReference',
                           recurring_detail_reference: 'disableRequest.recurringDetailReference' }.freeze

    attr_accessor *REQUEST_ATTRIBUTES

    def initialize(params = {})
     @action                      = params.fetch(:action, 'Recurring.disable')
     @merchant_account            = params.fetch(:merchant_account, nil)
     @shopper_reference           = params.fetch(:shopper_reference, nil)
     @recurring_detail_reference  = params.fetch(:recurring_detail_reference, nil)
    end

    def build_adyen_params
      raise Adyen::Error::ApiRequest, "Cannot build valid request from parameters supplied." unless valid?
      REQUEST_ATTRIBUTES.inject({}){ |memo, attr| memo[ADYEN_REQUEST_KEYS[attr]] = self.send(attr) if self.send(attr); memo }
    end

    def valid?
      action &&
      merchant_account &&
      shopper_reference &&
      recurring_detail_reference
    end

  end
end
