require 'rails_helper'

describe Marketplace::Accounts::CourierFee do
  include Factories::Marketplace

  describe "instance method" do
    describe "#calculate!" do
      before :each do
        @payment = create_payment
      end

      it "should create a new fee record" do
        orig_count = @payment.fees.reload.count
        Marketplace::Accounts::CourierFee.new(payment: @payment).calculate!
        expect(@payment.fees.reload.count).to eq orig_count+1
      end

      it "should set the currency code appropriate to the payment" do
        fee = Marketplace::Accounts::CourierFee.new(payment: @payment)
        expect(@payment.fees).to be_empty
        fee.calculate!
        expect(@payment.fees.first.currency_code).to eq @payment.currency_code
      end

      describe "where payment total is less than the threshold of 80EUR" do
        before :each do
          @payment.update_column(:amount_cents, 7500)
          @payment.reload
        end

        it "should set the amount_cents to a flat fee of 800 cents" do
          expect(@payment.fees.reload).to be_empty
          Marketplace::Accounts::CourierFee.new(payment: @payment).calculate!
          expect(@payment.fees.reload).not_to be_empty
          expect(@payment.fees.reload.where(type: "Marketplace::Accounts::CourierFee").first.amount_cents).to eq 800
        end
      end

      describe "where payment total exceeds the threshold of 80EUR" do
        before :each do
          @payment.update_column(:amount_cents, 10000)
          @payment.reload
        end

        it "should augment the flat fee with a 10% fee on the surplus" do
          expect(@payment.fees.reload).to be_empty
          Marketplace::Accounts::CourierFee.new(payment: @payment).calculate!
          expect(@payment.fees.reload).not_to be_empty
          expect(@payment.fees.reload.where(type: "Marketplace::Accounts::CourierFee").first.amount_cents).to eq 1000
        end
      end
    end
  end
end
