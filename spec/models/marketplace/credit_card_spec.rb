require 'rails_helper'

describe Marketplace::CreditCard do
  include Factories::Marketplace

  [ :pharmacy,
    :payments,
    :gateway_customer_reference,
    :holder_name,
    :brand,
    :number,
    :expiry_month,
    :expiry_year,
    :email,
    :pharmacy_name,
    :encrypted_card,
    :authorize! ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::CreditCard.new).to respond_to method
    end
  end

  before :all do
    @pharmacy = create_pharmacy
    @order = create_order(agent: create_agent(pharmacy: @pharmacy))
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
      @credit_card = @pharmacy.credit_cards.create(@params)
    end

    describe "#authorize!" do
      before :each do
        @response = PaymentGateway::AuthorizationResponse.new(OpenStruct.new({
          id: "cust_8765",
          sources: [ OpenStruct.new(last4: "9876", exp_month: "06", exp_year: "2023", name: "joe@doe.com", brand: "Visa") ]
        }))
        @unsuccessful_response = PaymentGateway::AuthorizationResponse.new(OpenStruct.new(status: "failed"))
        allow(PAYMENT_GATEWAY).to receive(:authorize).and_return(@response)
        @opts = { token: "tok_98765", order: @order }
      end

      it "should raise an error if payment not authorized" do
        allow(PAYMENT_GATEWAY).to receive(:authorize).and_return(@unsuccessful_response)
        expect{ @credit_card.authorize!(@opts) }.to raise_error Marketplace::Errors::PaymentError
      end

      it "should set the :gateway_customer_reference on the credit card" do
        expect(@credit_card.gateway_customer_reference).to be_nil
        @credit_card.authorize!(@opts)
        expect(@credit_card.gateway_customer_reference).not_to be_nil
        expect(@credit_card.gateway_customer_reference).to eq "cust_8765"
      end

      it "should set the :number on the credit card" do
        expect(@credit_card.number).to be_nil
        @credit_card.authorize!(@opts)
        expect(@credit_card.number).to eq "9876"
      end

      it "should set the :brand on the credit card" do
        expect(@credit_card.brand).to be_nil
        @credit_card.authorize!(@opts)
        expect(@credit_card.brand).to eq "Visa"
      end

      it "should set the :expiry_month on the credit card" do
        expect(@credit_card.expiry_month).to be_nil
        @credit_card.authorize!(@opts)
        expect(@credit_card.expiry_month).to eq 6
      end

      it "should set the :expiry_year on the credit card" do
        expect(@credit_card.expiry_year).to be_nil
        @credit_card.authorize!(@opts)
        expect(@credit_card.expiry_year).to eq 2023
      end
    end

    describe "#take_payment!" do
      before :each do
        @response = PaymentGateway::PurchaseResponse.new(OpenStruct.new(id: "ch_8765", status: "succeeded"))
        @unsuccessful_response = PaymentGateway::AuthorizationResponse.new(OpenStruct.new(status: "failed"))
        allow(PAYMENT_GATEWAY).to receive(:purchase).and_return(@response)
        @opts = { order: @order, currency_code: "EUR", amount_cents: 7699 }
      end

      describe "where credit card has existing :gateway_customer_reference" do
        before :each do
          @credit_card.gateway_customer_reference = "cust_9876"
          @credit_card.save!
        end

        it "should not call #authorize! on the credit card" do
          expect(@credit_card).not_to receive(:authorize!)
          @credit_card.take_payment!(@opts)
        end

        it "should create a new payment record" do
          orig_count = @credit_card.reload.payments.count
          @credit_card.take_payment!(@opts)
          expect(@credit_card.reload.payments.count).to eq orig_count+1
        end

        describe "payment record created" do
          before :each do
            @credit_card.payments.destroy_all
          end

          it "should set the :gateway_reference" do
            expect(@credit_card.payments.reload.count).to eq 0
            @credit_card.take_payment!(@opts)
            expect(@credit_card.payments.first.gateway_reference).not_to be_nil
          end

          it "should set the :result_code" do
            expect(@credit_card.payments.reload.count).to eq 0
            @credit_card.take_payment!(@opts)
            expect(@credit_card.payments.first.result_code).not_to be_nil
          end

          it "should set the :gateway_response" do
            expect(@credit_card.payments.reload.count).to eq 0
            @credit_card.take_payment!(@opts)
            expect(@credit_card.payments.first.gateway_response).not_to be_nil
          end
        end
      end

      describe "where credit card has no existing :gateway_customer_reference" do
        before :each do
          @credit_card.gateway_customer_reference = nil
          @credit_card.save!
          allow(PAYMENT_GATEWAY).to receive(:authorize).and_return(PaymentGateway::AuthorizationResponse.new(OpenStruct.new(id: "cust_8765")))
        end

        it "should first call #authorize! on the credit card" do
          expect(@credit_card).to receive(:authorize!).once
          @credit_card.take_payment!(@opts)
        end
      end
    end
  end

  describe "after_save" do
    before :all do
      @default_credit_card = @pharmacy.credit_cards.create!(@params.merge(default: true))
      @other_credit_card = @pharmacy.credit_cards.create!(@params.merge(default: false))
    end

    describe "if :default flag has been set to true" do
      it "should update other cards associated with same pharmacy to be non-default" do
        expect(@default_credit_card.reload.default).to be_truthy
        expect(@other_credit_card.reload.default).to be_falsey
        @other_credit_card.default = true
        @other_credit_card.save
        expect(@default_credit_card.reload.default).to be_falsey
        expect(@other_credit_card.reload.default).to be_truthy
      end
    end

    describe "if :default flag has not been set" do
      before :each do
        @other_credit_card.update_column(:default, true)
      end

      it "should not update other cards associated with same pharmacy to be non-default" do
        expect(@default_credit_card.reload.default).to be_truthy
        expect(@other_credit_card.reload.default).to be_truthy
        @other_credit_card.default = false
        @other_credit_card.save
        expect(@default_credit_card.reload.default).to be_truthy
        expect(@other_credit_card.reload.default).to be_falsey
      end
    end
  end
end
