require 'rails_helper'

describe PaymentGateway::Gateway do
  before :each do
    allow(Rails).to receive(:application) do
      OpenStruct.new(credentials: OpenStruct.new({ stripe: { secret: "mysecretapikeyforstripe" } }))
    end
    allow(Stripe).to receive(:api_key=).and_return(nil)
    allow(Stripe::Customer).to receive(:create).and_return(nil)
    allow(Stripe::Charge).to receive(:create).and_return(nil)
  end

  [:purchase, :authorize].each do |method|
    it "should respond to method :#{method}" do
      expect(PaymentGateway::Gateway).to respond_to method
    end
  end

  describe "class method" do
    describe "::purchase" do
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
        PaymentGateway::Gateway::purchase(@opts)
      end

      it "should invoke Stripe::Charge.create with expected arguments when customer supplied" do
        expect(Stripe::Charge).to receive(:create).with({
          amount: 7999,
          currency: "eur",
          customer: "cust_666",
          receipt_email: "dev@rev.com"
        })

        PaymentGateway::Gateway::purchase(@opts.merge(customer: "cust_666", token: nil))
      end

      it "should return an instance of PaymentGateway::PurchaseResponse" do
        expect(PaymentGateway::Gateway::purchase(@opts)).to be_a PaymentGateway::PurchaseResponse
      end
    end

    describe "::authorize" do
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
        PaymentGateway::Gateway::authorize(@opts)
      end

      it "should return an instance of PaymentGateway::AuthorizationResponse" do
        expect(PaymentGateway::Gateway::authorize(@opts)).to be_a PaymentGateway::AuthorizationResponse
      end
    end
  end
end
