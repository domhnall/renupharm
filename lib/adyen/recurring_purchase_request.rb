module Adyen
  class RecurringPurchaseRequest < PurchaseRequest

    ADYEN_REQUEST_KEYS = { selected_recurring_detail_reference: 'paymentRequest.selectedRecurringDetailReference',
                           shopper_interaction: 'paymentRequest.shopperInteraction' }.freeze

    ALLOWED_INTERACTIONS = %w( ContAuth Ecommerce ).freeze

    attr_accessor :selected_recurring_detail_reference,
                  :shopper_interaction

    def initialize(params = {})
      super
      @shopper_interaction                  = params.fetch(:shopper_interaction, 'ContAuth')
      @selected_recurring_detail_reference  = params.fetch(:selected_recurring_detail_reference, nil)
    end

    def build_adyen_params
      raise Adyen::Error::ApiRequest, "Cannot build valid request from parameters supplied." unless valid?
      super.merge({ ADYEN_REQUEST_KEYS[:selected_recurring_detail_reference] => self.selected_recurring_detail_reference,
                    ADYEN_REQUEST_KEYS[:shopper_interaction] => self.shopper_interaction })
    end

    def valid?
      super &&
      self.selected_recurring_detail_reference &&
      ALLOWED_INTERACTIONS.include?(self.shopper_interaction)
    end
  end
end
