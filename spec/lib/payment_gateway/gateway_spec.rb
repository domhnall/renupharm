require 'spec_helper'
require 'ostruct'
require 'byebug'
require_relative '../../../lib/payment_gateway/gateway'


describe PaymentGateway::Gateway do
  class Rails
    def self.application
      OpenStruct.new(credentials: OpenStruct.new({ stripe: { secret: "mysecretapikeyforstripe" } }))
    end
  end

  class Stripe
    def self.api_key=(key)
    end

    class Customer
      def self.create(args); end
    end

    class Charge
      def self.create(args); end
    end
  end

  [:purchase, :authorize].each do |method|
    it "should respond to method :#{method}" do
      expect(PaymentGateway::Gateway.new).to respond_to method
    end
  end

  describe "class method" do
    describe "::get_instance" do
      it "should return an instance of PaymentGateway::Gateway" do
        expect(PaymentGateway::Gateway::get_instance).to be_a PaymentGateway::Gateway
      end

      it "should return the same instance after multiple invocations" do
        expect(PaymentGateway::Gateway).to receive(:new).once.and_call_original
        instance = PaymentGateway::Gateway::get_instance
        expect(PaymentGateway::Gateway::get_instance).to eq instance
      end
    end
  end

  describe "instance method" do
    describe "#purchase" do
      before :all do
        @opts = {
          amount_value: 7999,
          amount_currency: "EUR",
          token: "tok_abcdefgh",
          email: "dev@rev.com"
        }
      end

      before :each do
        allow(Stripe::Charge).to receive(:create).and_return(OpenStruct.new(id: "ch_876"))
      end

      it "should invoke Stripe::Charge.create with expected arguments when token supplied" do
        expect(Stripe::Charge).to receive(:create).with({
          amount: 7999,
          currency: "eur",
          source: "tok_abcdefgh",
          receipt_email: "dev@rev.com"
        })
        PaymentGateway::Gateway.new.purchase(@opts)
      end

      it "should invoke Stripe::Charge.create with expected arguments when customer supplied" do
        expect(Stripe::Charge).to receive(:create).with({
          amount: 7999,
          currency: "eur",
          customer: "cust_666",
          receipt_email: "dev@rev.com"
        })

        PaymentGateway::Gateway.new.purchase(@opts.merge(customer: "cust_666", token: nil))
      end

      it "should return an instance of PaymentGateway::PurchaseResponse" do
        expect(PaymentGateway::Gateway.new.purchase(@opts)).to be_a PaymentGateway::PurchaseResponse
      end
    end

    describe "#authorize" do
      before :all do
        @opts = {
          user: OpenStruct.new(id: 67),
          token: "tok_654321"
        }
      end

      before :each do
        allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new(id: "cust_876"))
      end

      it "should invoke Stripe::Customer.create with expected arguments" do
        expect(Stripe::Customer).to receive(:create).with({
          description: kind_of(String),
          source: "tok_654321"
        })
        PaymentGateway::Gateway.new.authorize(@opts)
      end

      it "should return an instance of PaymentGateway::AuthorizationResponse" do
        expect(PaymentGateway::Gateway.new.authorize(@opts)).to be_a PaymentGateway::AuthorizationResponse
      end
    end
  end
end
