class PaymentGateway::AuthorizationRequest
  attr_reader :orig_opts

  def initialize(opts = {})
    @orig_opts = opts
  end

  def build
    { description: build_description,
      source: orig_opts.fetch(:token) }
  end

  private

  def build_description
    [ orig_opts.fetch(:user).id,
      Time.now.to_i ].join("_")
  end
end
