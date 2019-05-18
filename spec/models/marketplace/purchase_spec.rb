require 'rails_helper'

describe Marketplace::Purchase do
  include Factories::Base
  include Factories::Marketplace

  it "should be a kind of Marketplace::Order" do
    expect(Marketplace::Purchase.new).to be_a Marketplace::Order
  end

  describe "scope" do
    describe "::for_pharmacy" do
      before :all do
        @admin     = create_admin_user

        @seller    = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
        @product   = create_product(pharmacy: @seller)
        @listing_a = create_listing(product: @product)
        @listing_b = create_listing(product: @product)
        @listing_c = create_listing(product: @product)
        @listing_d = create_listing(product: @product)
        @listing_e = create_listing(product: @product)

        @buyer     = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com")
        @agent     = create_agent(pharmacy: @buyer)

        @order_a = create_order({ agent: @agent, listing: @listing_a, state: Marketplace::Order::State::IN_PROGRESS })
        @order_b = create_order({ agent: @agent, listing: @listing_b, state: Marketplace::Order::State::PLACED })
        @order_c = create_order({ agent: @agent, listing: @listing_c, state: Marketplace::Order::State::DELIVERY_IN_PROGRESS })
        @order_d = create_order({ agent: @agent, listing: @listing_d, state: Marketplace::Order::State::COMPLETED })
        @order_e = create_order({ agent: create_agent, listing: @listing_e, state: Marketplace::Order::State::COMPLETED })
      end

      it "should return any PENDING purchases by the pharmacy" do
        expect(Marketplace::Purchase.for_pharmacy(@buyer).pluck(:id)).to include @order_b.id
      end

      it "should return any DELIVERY_IN_PROGRESS purchases by the pharmacy" do
        expect(Marketplace::Purchase.for_pharmacy(@buyer).pluck(:id)).to include @order_c.id
      end

      it "should return any COMPLETED purchases by the pharmacy" do
        expect(Marketplace::Purchase.for_pharmacy(@buyer).pluck(:id)).to include @order_d.id
      end

      it "should not return any IN_PROGRESS orders by the pharmacy" do
        expect(Marketplace::Purchase.for_pharmacy(@buyer).pluck(:id)).not_to include @order_a.id
      end

      it "should not return any orders by another pharmacy" do
        expect(Marketplace::Purchase.for_pharmacy(@buyer).pluck(:id)).not_to include @order_e.id
      end
    end
  end
end
