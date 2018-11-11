#
# Example response:
#   recurringDetailsResult.shopperReference=jenkins%40examtime.com&recurringDetailsResult.details.0.variant=mc&recurringDetailsResult.details.0.card.number=1111&recurringDetailsResult.details.0.recurringDetailReference=8313988647341975&recurringDetailsResult.details.0.card.expiryMonth=6&recurringDetailsResult.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&recurringDetailsResult.lastKnownShopperEmail=jenkins%40examtime.com&recurringDetailsResult.details.0.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&recurringDetailsResult.details.0.card.expiryYear=2016&recurringDetailsResult.details.0.card.holderName=Joe+Tweets
#
module Adyen
  class ListRecurringResponse
    class Detail
      attr_accessor :variant,
                    :recurring_detail_reference,
                    :creation_date,
                    :card_number,
                    :card_expiry_month,
                    :card_expiry_year,
                    :card_holder_name

      ADYEN_RESPONSE_KEYS = { variant: 'variant',
                              recurring_detail_reference: 'recurringDetailReference',
                              creation_date: 'creationDate',
                              card_number: 'card.number',
                              card_expiry_month: 'card.expiryMonth',
                              card_expiry_year: 'card.expiryYear',
                              card_holder_name: 'card.holderName' }.freeze

      def initialize(attrs = {})
        inverted_keys = ADYEN_RESPONSE_KEYS.invert
        attrs.each do |k,v|
          self.send("#{inverted_keys[k]}=", v) if inverted_keys[k]
        end
      end
    end

    attr_accessor :shopper_reference,
                  :creation_date,
                  :last_known_shopper_email,
                  :details

    ADYEN_RESPONSE_KEYS = { shopper_reference: 'recurringDetailsResult.shopperReference',
                            creation_date: 'recurringDetailsResult.creationDate',
                            last_known_shopper_email: 'recurringDetailsResult.lastKnownShopperEmail' }.freeze

    def initialize(response_str)
      response_str.force_encoding(Encoding::ISO_8859_1)
      if response_str.blank?
        raise Adyen::Error::ApiResponse, 'Cannot instantiate with an empty response string'
      end
      response_str = CGI.unescape(response_str)
      parsed = Hash[response_str.split('&').map{ |pair| pair.encode('utf-8').split('=') }]
      ADYEN_RESPONSE_KEYS.each do |attr, key|
        if parsed[ADYEN_RESPONSE_KEYS[attr]]
          self.instance_variable_set("@#{attr}".to_sym, parsed[ADYEN_RESPONSE_KEYS[attr]])
        end
      end
      # Now parse details
      self.details = []
      details_key = 'recurringDetailsResult.details'
      total_cards = parsed.select{ |k,v| k=~/#{details_key}/ }
                          .map{ |k,v| k.split('.')[2].to_i }.max
      if total_cards
        (0..total_cards).each do |i|
          detail_attrs = parsed.select{ |k,v| k.split('.')[2]==i.to_s }
                              .inject({}){ |memo, (k,v)| memo[k.sub("#{details_key}.#{i}.",'')]=v; memo }
          self.details << Detail.new(detail_attrs)
        end
        self.details.sort_by!(&:creation_date)
      end
    end
  end
end
