class PaymentGateway::PurchaseRequest
  attr_reader :orig_opts

  def initialize(opts = {})
    @orig_opts = opts
  end

  def build
    { amount: orig_opts.fetch(:amount_value),
      currency: orig_opts.fetch(:amount_currency).downcase,
      source: orig_opts.fetch(:token, nil),
      customer: orig_opts.fetch(:customer, nil),
      receipt_email: orig_opts.fetch(:email) }.compact
  end
end
