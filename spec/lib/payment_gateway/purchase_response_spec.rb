require 'spec_helper'
require_relative '../../../lib/payment_gateway/purchase_response'

describe PaymentGateway::PurchaseResponse do
  before :all do
    @charge = OpenStruct.new({
      id: "987",
      status: "succeeded"
    })
  end

  [:charge, :authorized?, :reference, :result_code, :json_response].each do |method|
    it "should respond to method :#{method}" do
      expect(PaymentGateway::PurchaseResponse.new(@charge)).to respond_to method
    end
  end

  describe "instantiation" do
    it "should raise an error if no charge is supplied" do
      expect{ PaymentGateway::PurchaseResponse.new }.to raise_error ArgumentError
    end
  end

  describe "instance method" do
    describe "#reference" do
      it "should return the ID form the charge object passed" do
        expect(PaymentGateway::PurchaseResponse.new(@charge).reference).to eq "987"
      end

      it "should return nil if the charge object has no associated ID" do
        charge = OpenStruct.new({ status: "failed" })
        expect(PaymentGateway::PurchaseResponse.new(charge).reference).to be_nil
      end
    end

    describe "#result_code" do
      it "should return the status code from the charge object passed" do
        expect(PaymentGateway::PurchaseResponse.new(@charge).result_code).to eq "succeeded"
      end
    end

    describe "#authorized?" do
      it "should return true if successful status returned" do
        expect(PaymentGateway::PurchaseResponse.new(@charge).authorized?).to be_truthy
      end

      it "should return true if successful status returned" do
        charge = OpenStruct.new({ status: "pending" })
        expect(PaymentGateway::PurchaseResponse.new(charge).authorized?).to be_falsey
      end
    end

    describe "#json_response" do
      it "should return a Hash" do
        expect(PaymentGateway::PurchaseResponse.new(@charge).json_response).to be_a Hash
      end
    end
  end
end
