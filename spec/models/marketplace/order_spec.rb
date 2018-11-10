require 'rails_helper'

describe Marketplace::Order do
  include Factories::Base
  include Factories::Marketplace

  [ :state,
    :agent,
    :user,
    :line_items ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Order.new).to respond_to method
    end
  end

  before :all do
    @seller = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
    @product = create_product(pharmacy: @seller)
    @pharmacy = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com")
    @agent = create_agent(pharmacy: @pharmacy)
  end

  describe "instantiation" do
    before :all do
      @params = {
        agent: @agent,
        state: ::Marketplace::Order::State::IN_PROGRESS
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Order.new(@params)).to be_valid
    end

    it "should not be valid when :agent is not supplied" do
      expect(Marketplace::Order.new(@params.merge(agent: nil, marketplace_agent_id: nil))).not_to be_valid
    end

    Marketplace::Order::State::valid_states do |state|
      it "should be valid when state is '#{state}'" do
        expect(Marketplace::Order.new(@params.merge(state: state))).to be_valid
      end
    end

    %w(refunded cancelled rubbish voided).each do |state|
      it "should be invalid when state is '#{state}'" do
        expect(Marketplace::Order.new(@params.merge(state: state))).not_to be_valid
      end
    end

    it "should be valid when order has zero line items" do
      order = Marketplace::Order.new(@params)
      expect(order.line_items.count).to eq 0
      expect(order).to be_valid
    end

    it "should be valid when order has one line item" do
      order = Marketplace::Order.create(@params).tap do |order|
        order.line_items = [Marketplace::LineItem.new(order: order, listing: create_listing(pharmacy: @pharmacy))]
      end
      expect(order.line_items.count).to eq 1
      expect(order).to be_valid
    end

    it "should be invalid when order has more than one line items" do
      product = create_product(pharmacy: @pharmacy)
      order = Marketplace::Order.create(@params).tap do |order|
        order.line_items = [
          Marketplace::LineItem.new(order: order, listing: create_listing(product: product)),
          Marketplace::LineItem.new(order: order, listing: create_listing(product: product))
        ]
      end
      expect(order.line_items.count).to eq 2
      expect(order).not_to be_valid
    end
  end

  describe "instance method" do
    before :each do
      @order = Marketplace::Order.create({
        agent: @agent,
        state: ::Marketplace::Order::State::IN_PROGRESS
      }).tap do |order|
        order.line_items.create(listing: create_listing(product: @product))
      end
    end

    describe "#product" do
      it "should return the product associated with the first line item of the order" do
        expect(@order.product).to eq @product
      end

      it "should return nil if the order has no associated line items" do
        @order.line_items = []
        expect(@order.product).to be_nil
      end
    end

    describe "#seller" do
      it "should return the seller associated with the first line item of the order" do
        expect(@order.seller).to eq @seller
      end

      it "should return nil if the order has no associated line items" do
        @order.line_items = []
        expect(@order.seller).to be_nil
      end
    end
  end
end
