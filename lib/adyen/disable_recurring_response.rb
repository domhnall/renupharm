module Adyen
  class DisableRecurringResponse
    ADYEN_RESULT_CODES = %w( [detail-successfully-disabled] ).freeze

    ADYEN_RESPONSE_KEYS = { response: 'disableResult.response' }.freeze

    attr_accessor :response

    def initialize(response_str)
      if response_str.blank?
        raise Adyen::Error::ApiResponse, 'Response string must be supplied to instantiate'
      end

      response_str = CGI.unescape(response_str)
      parsed = Hash[response_str.split('&').map{ |pair| pair.split('=') }]

      ADYEN_RESPONSE_KEYS.each do |attr, key|
        self.instance_variable_set("@#{attr}".to_sym, parsed[ADYEN_RESPONSE_KEYS[attr]])
      end

      unless ADYEN_RESULT_CODES.include?(self.response)
        raise Adyen::Error::ApiResponse, ":response should be one of #{ADYEN_RESULT_CODES.join(', ')}"
      end
    end
  end
end
