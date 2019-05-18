class Services::Marketplace::FeesCalculator
  attr_reader :payment

  def initialize(payment: nil)
    raise ArgumentError, "Must supply payment" unless payment
    @payment = payment
  end

  def call
    [ Marketplace::Accounts::SellerFee,
      Marketplace::Accounts::CourierFee,
      Marketplace::Accounts::PaymentGatewayFee,
      Marketplace::Accounts::ResidualFee ].each do |calculator|
      calculator.new(payment: payment).calculate!
    end
  end
end
