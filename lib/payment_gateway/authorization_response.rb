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

  def card_digits
    card.last4
  end

  def card_brand
    card.brand
  end

  def card_name
    card.name
  end

  def card_exp_month
    card.exp_month
  end

  def card_exp_year
    card.exp_year
  end

  def json_response
    customer.to_h
  end

  private

  def card
    customer.sources.first
  end
end
