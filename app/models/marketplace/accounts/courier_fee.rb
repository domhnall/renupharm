class Marketplace::Accounts::CourierFee < Marketplace::Accounts::Fee
  COURIER_FEE_CENTS = 750

  def calculate!
    payment.fees.create!({
      type: "Marketplace::Accounts::CourierFee",
      amount_cents: calculate_courier_fee,
      currency_code: payment.currency_code
    })
  end

  private

  def calculate_courier_fee
    # Based on current 6.1% surcharge for fuel
    COURIER_FEE_CENTS*1.061
  end
end
