require 'rails_helper'

describe Marketplace::Accounts::Fee do
  [ :payment,
    :amount_cents,
    :currency_code,
    :buying_pharmacy,
    :selling_pharmacy,
    :calculate! ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::Accounts::Fee.new).to respond_to method
    end
  end
  describe "instantiation" do
    before :all do
      @params = {
        payment: Marketplace::Payment.new,
        amount_cents: 999,
        currency_code: "EUR"
      }
    end

    it "should be valid where all required parameters are supplied" do
      expect(Marketplace::Accounts::Fee.new(@params)).to be_valid
    end

    it "should be invalid where :amount_cents is not supplied" do
      expect(Marketplace::Accounts::Fee.new(@params.merge(amount_cents: nil))).not_to be_valid
    end

    it "should be invalid where :currency_code is not supplied" do
      expect(Marketplace::Accounts::Fee.new(@params.merge(currency_code: nil))).not_to be_valid
    end
  end

  describe "instance method" do
    describe "#calculate!" do
      it "should raise a NotImplementedError" do
        expect{ Marketplace::Accounts::Fee.new.calculate! }.to raise_error NotImplementedError
      end
    end
  end
end
