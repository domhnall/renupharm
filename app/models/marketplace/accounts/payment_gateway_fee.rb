class Marketplace::Accounts::PaymentGatewayFee < Marketplace::Accounts::Fee
  FLAT_RATE_CENTS = 25
  TRANSACTION_RATE = 0.014

  def calculate!
    payment.fees.create!({
      type: "Marketplace::Accounts::PaymentGatewayFee",
      amount_cents: calculate_payment_gateway_fee,
      currency_code: payment.currency_code
    })
  end

  private

  def calculate_payment_gateway_fee
    FLAT_RATE_CENTS + payment.amount_cents*TRANSACTION_RATE
  end
end
