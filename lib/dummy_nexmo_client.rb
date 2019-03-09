class DummyNexmoClient
  attr_reader :log_method

  def initialize(**args)
    @log_method = args.fetch(:log_method){ Rails.logger.method(:warn) }
  end

  def sms
    self
  end

  def send(opts = {})
    log("DummyNexmoClient:: Called #send with #{opts}")
    default_response(opts).deep_merge(opts.fetch(:response, {}))
  end

  private

  def log(msg)
    log_method.call(msg)
  end

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
