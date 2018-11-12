require 'rails_helper'

describe Marketplace::CreditCard do
  include Factories::Marketplace

  [ :pharmacy,
    :payments,
    :recurring_detail_reference,
    :holder_name,
    :brand,
    :number,
    :expiry_month,
    :expiry_year,
    :email,
    :pharmacy_name,
    :encrypted_card,
    :shopper_ip,
    :authorize! ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::CreditCard.new).to respond_to method
    end
  end

  before :all do
    @pharmacy = create_pharmacy
    @params = {
      pharmacy: @pharmacy,
      email: "sydney@parade.com"
    }
  end

  describe "instantiation" do
    it "should be valid when all mandatory fields are supplied" do
      expect(Marketplace::CreditCard.new(@params)).to be_valid
    end

    it "should be invalid without an associated pharmacy" do
      expect(Marketplace::CreditCard.new(@params.merge(pharmacy: nil))).not_to be_valid
    end

    it "should be invalid when :email is not supplied" do
      expect(Marketplace::CreditCard.new(@params.merge(email: nil))).not_to be_valid
    end
  end

  describe "instance method" do
    before :each do
      @response = Adyen::PurchaseResponse.new("paymentResult.pspReference=7913990310819176&paymentResult.authCode=61824&paymentResult.resultCode=Authorised")
      @unsuccessful_response = Adyen::PurchaseResponse.new("paymentResult.pspReference=8513988005309240&paymentResult.resultCode=Refused")
      allow(PAYMENT_GATEWAY).to receive(:purchase).and_return(@response)
      @credit_card = @pharmacy.credit_cards.create(@params)
    end

    describe "#authorize!" do
      it "should create a new payment record" do
        orig_count = @credit_card.reload.payments.count
        @credit_card.authorize!
        expect(@credit_card.reload.payments.count).to eq orig_count+1
      end

      it "should raise an error if payment not authorized" do
        allow(PAYMENT_GATEWAY).to receive(:purchase).and_return(@unsuccessful_response)
        expect{ @credit_card.authorize! }.to raise_error Marketplace::Errors::PaymentError
      end

      describe "payment record created" do
        before :each do
          @credit_card.payments.destroy_all
        end

        it "should set the :gateway_reference" do
          expect(@credit_card.payments.reload.count).to eq 0
          @credit_card.authorize!
          expect(@credit_card.payments.first.gateway_reference).not_to be_nil
        end

        it "should set the :result_code" do
          expect(@credit_card.payments.reload.count).to eq 0
          @credit_card.authorize!
          expect(@credit_card.payments.first.result_code).not_to be_nil
        end

        it "should set the :auth_code" do
          expect(@credit_card.payments.reload.count).to eq 0
          @credit_card.authorize!
          expect(@credit_card.payments.first.auth_code).not_to be_nil
        end
      end

      # The recurring_detail_reference is only retrieved later (async)
      #it "should set the :recurring_detail_reference on the credit card" do
      #  expect(@credit_card.recurring_detail_reference).to be_nil
      #  @credit_card.authorize!
      #  expect(@credit_card.recurring_detail_reference).not_to be_nil
      #end
    end
  end
end
