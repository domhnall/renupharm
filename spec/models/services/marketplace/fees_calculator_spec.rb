require 'rails_helper'

describe Services::Marketplace::FeesCalculator do
  include Factories::Marketplace

  before :each do
    @payment = create_payment
    @params = { payment: @payment }
  end

  [ :payment,
    :call ].each do |method|
    it "should respond to method :#{method}" do
      expect(Services::Marketplace::FeesCalculator.new(@params)).to respond_to method
    end
  end

  describe "initialization" do
    it "should not raise an error if all required params are supplied" do
      expect{ Services::Marketplace::FeesCalculator.new(@params) }.not_to raise_error
    end

    it "should raise an error if payment is not supplied" do
      expect{ Services::Marketplace::FeesCalculator.new(@params.merge(payment: nil)) }.to raise_error ArgumentError
    end
  end

  describe "instance method" do
    before :each do
      @service = Services::Marketplace::FeesCalculator.new(@params)
    end

    describe "#call" do
      it "should create a new SellerFee for the payment" do
        expect(@payment.fees.count).to eq 0
        @service.call
        expect(@payment.fees.where(type: "Marketplace::Accounts::SellerFee").count).to eq 1
      end

      it "should create a new CourierFee for the payment" do
        expect(@payment.fees.count).to eq 0
        @service.call
        expect(@payment.fees.where(type: "Marketplace::Accounts::CourierFee").count).to eq 1
      end

      it "should create a new PaymentGatewayFee for the payment" do
        expect(@payment.fees.count).to eq 0
        @service.call
        expect(@payment.fees.where(type: "Marketplace::Accounts::PaymentGatewayFee").count).to eq 1
      end

      it "should create a new ResidualFee for the payment" do
        expect(@payment.fees.count).to eq 0
        @service.call
        expect(@payment.fees.where(type: "Marketplace::Accounts::ResidualFee").count).to eq 1
      end
    end
  end
end
