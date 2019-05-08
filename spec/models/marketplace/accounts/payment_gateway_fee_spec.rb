require 'rails_helper'

describe Marketplace::Accounts::PaymentGatewayFee do
  include Factories::Marketplace

  describe "instance method" do
    describe "#calculate!" do
      before :each do
        @payment = create_payment
      end

      it "should create a new fee record" do
        orig_count = @payment.fees.reload.count
        Marketplace::Accounts::PaymentGatewayFee.new(payment: @payment).calculate!
        expect(@payment.fees.reload.count).to eq orig_count+1
      end

      it "should set the currency code appropriate to the payment" do
        fee = Marketplace::Accounts::PaymentGatewayFee.new(payment: @payment)
        expect(@payment.fees).to be_empty
        fee.calculate!
        expect(@payment.fees.first.currency_code).to eq @payment.currency_code
      end

      it "should set the amount_cents to a flat fee of 25 cents plus 1.4%" do
        @payment.update_column(:amount_cents, 7500)
        expect(@payment.fees.reload).to be_empty
        Marketplace::Accounts::PaymentGatewayFee.new(payment: @payment).calculate!
        expect(@payment.fees.reload).not_to be_empty
        expect(@payment.fees.reload.where(type: "Marketplace::Accounts::PaymentGatewayFee").first.amount_cents).to eq 130
      end
    end
  end
end
