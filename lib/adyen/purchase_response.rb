#
# Example response:
#   paymentResult.pspReference=8513988005309240&paymentResult.refusalReason=Please+supply+paymentDetails&paymentResult.resultCode=Refused
#
module Adyen
  class PurchaseResponse
    ADYEN_RESULT_CODES = %w( Authorised Refused Error Received RedirectShopper).freeze

    ADYEN_RESPONSE_KEYS = { psp_reference: 'paymentResult.pspReference',
                            result_code: 'paymentResult.resultCode',
                            auth_code: 'paymentResult.authCode',
                            refusal_reason: 'paymentResult.refusalReason',
                            pa_request: 'paymentResult.paRequest',
                            md: 'paymentResult.md',
                            issuer_url: 'paymentResult.issuer_url' }.freeze

    attr_accessor :psp_reference,
                  :result_code,
                  :auth_code,
                  :refusal_reason,
                  :pa_request,
                  :md,
                  :issuer_url

    def initialize(response_str)
      if response_str.blank?
        raise Adyen::Error::ApiResponse, 'Response string must be supplied to instantiate'
      end
      response_str = CGI.unescape(response_str)
      parsed = Hash[response_str.split('&').map{ |pair| pair.split('=') }]
      ADYEN_RESPONSE_KEYS.each do |attr, key|
        self.instance_variable_set("@#{attr}".to_sym, parsed[ADYEN_RESPONSE_KEYS[attr]])
      end

      # Apply some validations to the response
      unless (self.psp_reference && self.result_code)
        raise Adyen::Error::ApiResponse, "Response should define at least :psp_reference and :result_code"
      end

      unless ADYEN_RESULT_CODES.include?(self.result_code)
        raise Adyen::Error::ApiResponse, ":result_code should be one of #{ADYEN_RESULT_CODES.join(', ')}"
      end
    end

    ADYEN_RESULT_CODES.each do |adyen_code|
      method_name = "#{adyen_code.underscore}?".to_sym
      define_method(method_name) do
        self.result_code==adyen_code
      end
    end
  end
end
