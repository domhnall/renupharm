class Marketplace::Accounts::SellerFee < Marketplace::Accounts::Fee
  SELLER_RATE = 0.95

  def calculate!
    payment.fees << Marketplace::Accounts::SellerFee.new({
      amount_cents: payment.amount_cents*SELLER_RATE,
      currency_code: payment.currency_code
    })
  end
end
