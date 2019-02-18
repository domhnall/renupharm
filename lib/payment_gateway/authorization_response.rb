require_relative '../payment_gateway'

class PaymentGateway::AuthorizationResponse
  attr_reader :customer

  def initialize(customer = nil)
    raise ArgumentError, "A Customer object must be supplied" unless customer
    @customer = customer
  end

  def authorized?
    !!customer_reference
  end

  def customer_reference
    customer.id
  end

  def json_response
    customer.to_h
  end
end
