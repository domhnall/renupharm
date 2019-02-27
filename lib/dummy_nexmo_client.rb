class DummyNexmoClient
  attr_reader :log_method

  def initialize(log_method: Rails.logger.info)
    @log_method = log_method
  end

  def sms
    self
  end

  def send(opts = {})
    Rails.logger.warn("DummyNexmoClient:: Called #send with #{opts}")
    default_response(opts).deep_merge(opts.fetch(:response, {}))
  end

  private

  def default_response(opts)
    {
      "message-count": 1,
      "messages": [
        {
          "to": opts.fetch(:to),
          "message-id": rand.to_s[2..13],
          "status": "0",
          "remaining-balance": "19.99",
          "message-price": "0.03330000",
          "network": "12345" 
        }
      ]
    }
  end
end
