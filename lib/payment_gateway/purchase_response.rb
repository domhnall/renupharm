require_relative '../payment_gateway'

class PaymentGateway::PurchaseResponse
  SUCCEEDED = "succeeded"
  PENDING   = "pending"
  FAILED    = "failed"

  attr_reader :charge

  def initialize(charge = nil)
    raise ArgumentError, "A Charge object must be supplied" unless charge
    @charge = charge
  end

  def authorized?
    result_code==SUCCEEDED
  end

  def reference
    return unless authorized?
    charge.id
  end

  def result_code
    charge.status
  end

  def json_response
    charge.to_h
  end
end
