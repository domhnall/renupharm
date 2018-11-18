require 'rails_helper'

describe Marketplace::Payment do
  include Factories::Marketplace

  [ :order,
    :credit_card,
    :renupharm_reference,
    :gateway_reference,
    :reference,
    :amount_cents,
    :currency_code ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::Payment.new).to respond_to method
    end
  end

  before :all do
    @selling_pharmacy = create_pharmacy(name: "SellUrSoul", email: "sally@seller.com").tap do |pharmacy|
      @listing = create_listing(pharmacy: pharmacy)
    end

    @buying_pharmacy = create_pharmacy(name: "BuyerBWare", email: "billy@buyer.com").tap do |pharmacy|
      @buyer = create_agent(pharamcy: pharmacy)
      @credit_card = create_credit_card(pharmacy: pharmacy)
    end

    @order = create_order(agent: @buyer, listing: @listing)

    @params = {
      order: @order,
      credit_card: @credit_card,
      amount_cents: @order.price_cents,
      currency_code: "EUR"
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Marketplace::Payment.new(@params)).to be_valid
    end

    # If we are doing an authorization payment to validate a card
    it "should be valid without an associated :order" do
      expect(Marketplace::Payment.new(@params.merge(order: nil))).to be_valid
    end

    it "should be invalid without an associated :credit_card" do
      expect(Marketplace::Payment.new(@params.merge(credit_card: nil))).not_to be_valid
    end

    it "should default the :amount_cents to the value on the order" do
      expect(Marketplace::Payment.new(@params.merge(amount_cents: nil)).amount_cents).to eq @order.price_cents
    end

    it "should default the :currency_code to EUR" do
      expect(Marketplace::Payment.new(@params.merge(currency_code: nil)).currency_code).to eq "EUR"
    end

    it "should be invalid without an :amount_cents" do
      payment = Marketplace::Payment.new(@params).tap do |payment|
        payment.amount_cents = nil
      end
      expect(payment).not_to be_valid
    end

    it "should be invalid without a :currency_code" do
      payment = Marketplace::Payment.new(@params).tap do |payment|
        payment.currency_code = nil
      end
      expect(payment).not_to be_valid
    end
  end

  describe "on save" do
    before :each do
      @payment = Marketplace::Payment.new(@params)
    end

    it "should set the :renupharm_reference" do
      expect(@payment.renupharm_reference).to be_nil
      @payment.save!
      expect(@payment.renupharm_reference).not_to be_nil
    end
  end

  describe "instance method" do
    before :each do
      @payment = Marketplace::Payment.new(@params)
    end

    describe "#reference" do
      it "should return the :renupharm_reference" do
        expect(@payment.reference).to eq @payment.renupharm_reference
        @payment.renupharm_reference = "Hip-hop. Hippedy-hip-hop don't stop"
        expect(@payment.reference).to eq @payment.renupharm_reference
      end
    end
  end
end
