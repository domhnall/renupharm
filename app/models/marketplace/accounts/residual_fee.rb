class Marketplace::Accounts::ResidualFee < Marketplace::Accounts::Fee
  def calculate!
    payment.fees.create!({
      type: "Marketplace::Accounts::ResidualFee",
      amount_cents: payment.amount_cents - payment.reload.fees.sum(:amount_cents),
      currency_code: payment.currency_code
    })
  end
end
