class Marketplace::Accounts::CourierFee < Marketplace::Accounts::Fee
  FLAT_FEE_CENTS = 0
  FLAT_FEE_THRESHOLD_CENTS = 8000
  SURPLUS_PERCENT_FEE = 0

  def calculate!
    payment.fees.create!({
      type: "Marketplace::Accounts::CourierFee",
      amount_cents: calculate_courier_fee,
      currency_code: payment.currency_code
    })
  end

  private

  def calculate_courier_fee
    FLAT_FEE_CENTS + surplus*SURPLUS_PERCENT_FEE
  end

  def surplus
    [(payment.amount_cents-FLAT_FEE_THRESHOLD_CENTS), 0].max
  end
end
