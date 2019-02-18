require_relative '../payment_gateway'
require_relative './purchase_request'
require_relative './purchase_response'
require_relative './authorization_request'
require_relative './authorization_response'


class PaymentGateway::Gateway
  @@instance = nil

  def self.get_instance
    @@instance ||= new
  end

  def initialize
    Stripe.api_key = Rails.application.credentials.stripe[:secret]
  end

  def purchase(opts = {})
    stripe_request = PaymentGateway::PurchaseRequest.new(opts)
    PaymentGateway::PurchaseResponse.new(Stripe::Charge.create(stripe_request.build))
  end

  def authorize(opts = {})
    stripe_request = PaymentGateway::AuthorizationRequest.new(opts)
    PaymentGateway::AuthorizationResponse.new(Stripe::Customer.create(stripe_request.build))
  end
end
