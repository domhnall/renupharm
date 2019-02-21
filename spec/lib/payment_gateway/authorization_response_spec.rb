require 'spec_helper'
require_relative '../../../lib/payment_gateway/authorization_response'

describe PaymentGateway::AuthorizationResponse do
  before :all do
    @customer = OpenStruct.new({
      id: "cust_987",
      sources: [OpenStruct.new({
        last4: "4242",
        brand: "Visa",
        country: "US",
        name: "reg@renupharm.ie",
        exp_month: 5,
        exp_year: 2022
      })]
    })
  end

  [ :customer,
    :authorized?,
    :customer_reference,
    :json_response,
    :card_digits,
    :card_brand,
    :card_name,
    :card_exp_month,
    :card_exp_year ].each do |method|
    it "should respond to method :#{method}" do
      expect(PaymentGateway::AuthorizationResponse.new(@customer)).to respond_to method
    end
  end

  describe "instantiation" do
    it "should raise an error if no customer is supplied" do
      expect{ PaymentGateway::AuthorizationResponse.new }.to raise_error ArgumentError
    end
  end

  describe "instance method" do
    describe "#customer_reference" do
      it "should return the ID form the customer object passed" do
        expect(PaymentGateway::AuthorizationResponse.new(@customer).customer_reference).to eq "cust_987"
      end

      it "should return nil if the charge object has no associated ID" do
        customer = OpenStruct.new({ status: "failed" })
        expect(PaymentGateway::AuthorizationResponse.new(customer).customer_reference).to be_nil
      end
    end

    describe "#authorized?" do
      it "should return true if customer object with ID returned" do
        expect(PaymentGateway::AuthorizationResponse.new(@customer).authorized?).to be_truthy
      end

      it "should return true if successful status returned" do
        charge = OpenStruct.new({ status: "pending" })
        expect(PaymentGateway::AuthorizationResponse.new(charge).authorized?).to be_falsey
      end
    end

    describe "#json_response" do
      it "should return a Hash" do
        expect(PaymentGateway::AuthorizationResponse.new(@customer).json_response).to be_a Hash
      end
    end
  end
end
