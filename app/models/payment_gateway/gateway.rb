class PaymentGateway::Gateway
  def self.purchase(opts = {})
    stripe_request = ::PaymentGateway::PurchaseRequest.new(opts)
    ::PaymentGateway::PurchaseResponse.new(Stripe::Charge.create(stripe_request.build))
  end

  def self.authorize(opts = {})
    stripe_request = ::PaymentGateway::AuthorizationRequest.new(opts)
    ::PaymentGateway::AuthorizationResponse.new(::Stripe::Customer.create(stripe_request.build))
  end
end
