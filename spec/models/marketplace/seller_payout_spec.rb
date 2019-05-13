require 'rails_helper'

describe Marketplace::SellerPayout do
  include Factories::Base
  include Factories::Marketplace

  [ :user,
    :pharmacy,
    :orders ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::SellerPayout.new).to respond_to method
    end
  end

  before :all do
    @seller    = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
    @product   = create_product(pharmacy: @seller)
    @listing_1 = create_listing(product: @product, price_cents: 5000, purchased_at: Time.now-90.days)
    @listing_2 = create_listing(product: @product, price_cents: 4000, purchased_at: Time.now-45.days)
    @listing_3 = create_listing(product: @product, price_cents: 4500, purchased_at: Time.now-15.days)

    @buyer     = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com")
    @agent     = create_agent(pharmacy: @buyer)
    @order_1   = create_order(agent: @agent, listing: @listing_1, state: Marketplace::Order::State::COMPLETED)
    @order_2   = create_order(agent: @agent, listing: @listing_2, state: Marketplace::Order::State::COMPLETED)
    @order_3   = create_order(agent: @agent, listing: @listing_3, state: Marketplace::Order::State::COMPLETED)
    @admin     = create_admin_user
  end


  describe "instantiation" do
    before :each do
      @params = {
        pharmacy: @seller,
        user: @admin,
        orders: [@order_1, @order_2],
        total_cents: 9080,
        currency_code: "EUR"
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::SellerPayout.new(@params)).to be_valid
    end

    it "should be invalid when :pharmacy is not supplied" do
      expect(Marketplace::SellerPayout.new(@params.merge(pharmacy: nil))).not_to be_valid
    end

    it "should be invalid when :user is not supplied" do
      expect(Marketplace::SellerPayout.new(@params.merge(user: nil))).not_to be_valid
    end

    it "should be invalid when :total_cents is not supplied" do
      expect(Marketplace::SellerPayout.new(@params.merge(total_cents: nil))).not_to be_valid
    end

    it "should be invalid when :currency_code is not supplied" do
      expect(Marketplace::SellerPayout.new(@params.merge(currency_code: nil))).not_to be_valid
    end

    it "should be valid when :total_cents is greater than 2000" do
      expect(Marketplace::SellerPayout.new(@params.merge(total_cents: 2001))).to be_valid
    end

    it "should be invalid when :total_cents is 2000 or less" do
      expect(Marketplace::SellerPayout.new(@params.merge(total_cents: 500))).not_to be_valid
      expect(Marketplace::SellerPayout.new(@params.merge(total_cents: 1999))).not_to be_valid
      expect(Marketplace::SellerPayout.new(@params.merge(total_cents: 2000))).not_to be_valid
    end

    [ Marketplace::Order::State::IN_PROGRESS,
      Marketplace::Order::State::PLACED,
      Marketplace::Order::State::DELIVERY_IN_PROGRESS].each do |invalid_state|
      it "should be invalid when any order is in state '#{invalid_state}'" do
        @order_1.state = invalid_state
        expect(Marketplace::SellerPayout.new(@params)).not_to be_valid
      end
    end
  end
end
