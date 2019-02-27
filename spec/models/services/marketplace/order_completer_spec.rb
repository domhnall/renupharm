require 'rails_helper'

describe Services::Marketplace::OrderCompleter do
  include Factories::Marketplace

  before :all do
    @token = "token_98765"
    @email = "harry@hogwarts.com"
    @customer_reference = "cust_9876"

    @selling_pharmacy = create_pharmacy
    @active_listing = create_listing(pharmacy: @selling_pharmacy)
    @inactive_listing = create_listing(pharmacy: @selling_pharmacy, purchased_at: Time.now-1.hour)
    @buying_pharmacy = create_pharmacy.tap do |pharmacy|
      @agent = create_agent(pharmacy: pharmacy)
      @existing_card = create_credit_card(pharmacy: pharmacy, gateway_customer_reference: @customer_reference)
    end
  end

  before :each do
    @order = create_order(agent: @agent, listing: @active_listing)
    @params = {
      order: @order,
      token: @token,
      email: @email
    }
  end

  [ :order,
    :token,
    :email,
    :customer_reference,
    :call ].each do |method|
    it "should respond to method :#{method}" do
      expect(Services::Marketplace::OrderCompleter.new(@params)).to respond_to method
    end
  end

  describe "initialization" do
    it "should not raise an error if all required params are supplied" do
      expect{ Services::Marketplace::OrderCompleter.new(@params) }.not_to raise_error
    end

    it "should raise an error if order is not supplied" do
      expect{ Services::Marketplace::OrderCompleter.new(@params.merge(order: nil)) }.to raise_error ArgumentError
    end

    it "should raise an error where neither :token nor :customer_reference are supplied" do
      expect{ Services::Marketplace::OrderCompleter.new(@params.merge(token: nil, customer_reference: nil)) }.to raise_error ArgumentError
    end

    it "should raise an error where neither :email nor :customer_reference are supplied" do
      expect{ Services::Marketplace::OrderCompleter.new(@params.merge(email: nil, customer_reference: nil)) }.to raise_error ArgumentError
    end
  end

  describe "instance method" do
    before :each do
      @service = Services::Marketplace::OrderCompleter.new(@params)
      @auth_response = PaymentGateway::AuthorizationResponse.new(OpenStruct.new(
        id: "cust_8765",
        sources: [OpenStruct.new(
          last4: "9876",
          exp_month: "08",
          exp_year: "2023",
          name: "joe@example.com",
          brand: "MasterCard"
        )]
      ))
      allow(PAYMENT_GATEWAY).to receive(:authorize).and_return(@auth_response)
      @purchase_response = PaymentGateway::PurchaseResponse.new(OpenStruct.new(
        id: "ch_8765",
        status: "succeeded"
      ))
      allow(PAYMENT_GATEWAY).to receive(:purchase).and_return(@purchase_response)
    end

    describe "#call" do
      it "should return a Services::Response object" do
        expect(@service.call).to be_a Services::Response
      end

      it "should validate listing is available" do
        @order.line_items.create!(listing: @inactive_listing)
        expect(@service.call.errors.map(&:to_s)).to include I18n.t("marketplace.cart.errors.listing_unavailable")
      end

      it "should create a new credit card for the buying pharmacy if no customer_reference supplied" do
        orig_count = @buying_pharmacy.credit_cards.count
        @service.call
        expect(@buying_pharmacy.credit_cards.count).to eq orig_count+1
      end

      it "should not create a new credit card for the buying pharmacy when :gateway_customer_reference supplied" do
        orig_count = @buying_pharmacy.credit_cards.count
        Services::Marketplace::OrderCompleter.new(@params.merge(customer_reference: @customer_reference)).call
        expect(@buying_pharmacy.credit_cards.count).to eq orig_count
      end

      it "should create a payment for the order" do
        expect(@order.reload.payment).to be_nil
        @service.call
        expect(@order.reload.payment).not_to be_nil
      end

      describe "payment record created" do
        before :each do
          @service.call
          @payment = @order.payment
        end

        it "should have amount_cents matching the order total" do
          expect(@payment.amount_cents).to eq @order.price_cents
        end

        it "should have a currency_code corresponding to the value on the order" do
          expect(@payment.currency_code).to eq @order.currency_code
        end
      end

      it "should remove listing" do
        expect(@active_listing.reload.purchased_at).to be_nil
        @service.call
        expect(@active_listing.reload.purchased_at).not_to be_nil
      end

      %w( Marketplace::Accounts::SellerFee
          Marketplace::Accounts::CourierFee
          Marketplace::Accounts::PaymentGatewayFee
          Marketplace::Accounts::ResidualFee ).each do |fee_class|
        it "should calculate a single #{fee_class} record for the transaction" do
          orig_count = @order.fees.where(type: fee_class).count
          @service.call
          expect(@order.fees.where(type: fee_class).count).to eq orig_count+1
        end
      end

      describe "when error is thrown taking payment" do
        before :each do
          allow_any_instance_of(Marketplace::CreditCard).to receive(:take_payment!).and_raise Marketplace::Errors::PaymentError
          @service = Services::Marketplace::OrderCompleter.new(@params.merge(customer_reference: @customer_reference))
        end

        it "should return an error indicating that there was a problem taking the payment" do
          expect(@service.call.errors.map(&:to_s)).to include I18n.t("marketplace.cart.errors.failed_payment")
        end

        it "should call the admin error mailer" do
          expect(Admin::ErrorMailer).to receive(:payment_error).once.with(hash_including(order_id: @order.id)){ OpenStruct.new(deliver_later: true) }
          @service.call
        end
      end

      describe "when unexpected error is thrown" do
        before :each do
          allow(@service).to receive(:remove_listing).and_raise ArgumentError
        end

        it "should propagate the error up the stack" do
          expect{ @service.call }.to raise_error ArgumentError
        end

        it "should call the admin error mailer" do
          expect(Admin::ErrorMailer).to receive(:payment_error).once.with(hash_including(order_id: @order.id)){ OpenStruct.new(deliver_later: true) }
          expect{ @service.call }.to raise_error ArgumentError
        end
      end

      #it "should send notifications to appropriate agents" do
      #end

      #it "should raise a job with the courier" do
      #end

    end
  end
end
