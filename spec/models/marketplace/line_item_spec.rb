require 'rails_helper'

describe Marketplace::LineItem do
  include Factories::Marketplace

  [ :order,
    :listing,
    :product,
    :pharmacy,
    :quantity,
    :price_cents,
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
      @order = @buyer.orders.create
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
  end
end
