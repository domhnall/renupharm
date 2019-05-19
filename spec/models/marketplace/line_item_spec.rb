require 'rails_helper'

describe Marketplace::LineItem do
  include Factories::Marketplace

  [ :order,
    :listing,
    :product,
    :product_name,
    :selling_pharmacy,
    :pharmacy,
    :quantity,
    :price_cents,
    :expiry,
    :display_price ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::LineItem.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @selling_pharmacy = create_larussos
      @listing = create_listing(pharmacy: @selling_pharmacy)
      @buyer = create_agent(pharmacy: create_lawrences)
      @order = @buyer.orders.create(state: Marketplace::Order::State::IN_PROGRESS)
      @params = {
        order: @order,
        listing: @listing
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::LineItem.new(@params)).to be_valid
    end

    it "should not be valid when :order is not supplied" do
      expect(Marketplace::LineItem.new(@params.merge(order: nil, marketplace_order_id: nil))).not_to be_valid
    end

    it "should not be valid when :listing is not supplied" do
      expect(Marketplace::LineItem.new(@params.merge(listing: nil, marketplace_listing_id: nil))).not_to be_valid
    end

    it "should not be valid when order already has a line item for the same listing_id" do
      expect(@order.line_items.count).to eq 0
      Marketplace::LineItem.create!(@params)
      expect(@order.line_items.count).to eq 1
      expect(Marketplace::LineItem.new(@params)).not_to be_valid
    end
  end

  describe "destruction" do
    it "should be possible to destroy a line_item where order is IN_PROGRESS" do
      line_item = create_order(state: Marketplace::Order::State::IN_PROGRESS).line_items.first
      expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 1
      expect(line_item.destroy).to be_truthy
      expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 0
    end

    %w(completed delivering placed).each do |state|
      it "should not be possible to destroy a line_item where order is #{state}" do
        line_item = create_order(state: state).line_items.first
        expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 1
        expect(line_item.destroy).to be_falsey
        expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 1
      end
    end
  end
end
