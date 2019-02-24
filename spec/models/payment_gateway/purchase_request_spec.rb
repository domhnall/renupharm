require 'spec_helper'
require_relative '../../../app/models/payment_gateway'
require_relative '../../../app/models/payment_gateway/purchase_request'

describe PaymentGateway::PurchaseRequest do
  before :all do
    @options = {
      amount_value: 7999,
      amount_currency: "EUR",
      token: "abcdefgh",
      email: "dev@renupharm.ie"
    }
  end

  [ :build, :orig_opts ].each do |method|
    it "should respond to the method :#{method}" do
      expect(PaymentGateway::PurchaseRequest.new(@options)).to respond_to method
    end
  end

  describe "instance method" do
    describe "#build" do
      it "should return a Hash" do
        expect(PaymentGateway::PurchaseRequest.new(@options).build).to be_a Hash
      end

      describe "hash returned" do
        [:amount, :currency, :source, :receipt_email].each do |key|
          it "should include a key for :#{key}" do
            expect(PaymentGateway::PurchaseRequest.new(@options).build[key]).not_to be_nil
          end
        end

        it "should include the :customer key when this is supplied" do
          expect(PaymentGateway::PurchaseRequest.new(@options.merge(customer: "cust_123")).build[:customer]).not_to be_nil
        end

        it "should exclude the :source key when :token not supplied" do
          expect(PaymentGateway::PurchaseRequest.new(@options.merge(token: nil)).build.keys).not_to include :source
        end

        it "should exclude the :customer key when :customer not supplied" do
          expect(PaymentGateway::PurchaseRequest.new(@options.merge(customer: nil)).build.keys).not_to include :customer
        end

        it "should include the downcased currency code" do
          expect(PaymentGateway::PurchaseRequest.new(@options.merge(amount_currency: "USD")).build[:currency]).to eq "usd"
        end
      end
    end
  end
end
