require 'rails_helper'

describe Marketplace::Order do
  include Factories::Base
  include Factories::Marketplace

  [ :state,
    :agent,
    :user,
    :line_items,
    :listings,
    :payment,
    :fees,
    :price_cents,
    :price_major,
    :price_minor,
    :currency_symbol,
    :currency_code,
    :display_price,
    :bought_by?,
    :sold_by? ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Order.new).to respond_to method
    end
  end

  before :all do
    @seller    = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
    @product_a = create_product(pharmacy: @seller)
    @product_b = create_product(pharmacy: @seller)
    @pharmacy  = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com")
    @buyer     = @pharmacy
    @agent     = create_agent(pharmacy: @pharmacy)
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

    it "should be valid when order has a single line item" do
      order = Marketplace::Order.create(@params).tap do |order|
        order.line_items = [Marketplace::LineItem.new(order: order, listing: create_listing(pharmacy: @pharmacy))]
      end
      expect(order.line_items.count).to eq 1
      expect(order).to be_valid
    end

    it "should be valid when order has line items from a single seller" do
      order = Marketplace::Order.create(@params).tap do |order|
        order.line_items = [
          Marketplace::LineItem.new(order: order, listing: create_listing(pharmacy: @pharmacy)),
          Marketplace::LineItem.new(order: order, listing: create_listing(pharmacy: @pharmacy))
        ]
      end
      expect(order.line_items.count).to eq 2
      expect(order).to be_valid
    end

    it "should be invalid when order has line items from multiple sellers" do
      order = Marketplace::Order.create(@params).tap do |order|
        order.line_items = [
          Marketplace::LineItem.new(order: order, listing: create_listing),
          Marketplace::LineItem.new(order: order, listing: create_listing)
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
        order.line_items.create(listing: create_listing(product: @product_a))
        order.line_items.create(listing: create_listing(product: @product_b))
      end
    end

    describe "#product_names" do
      it "should return a string" do
        expect(@order.product_names).to be_a String
      end

      it "should return a comma separated list of the product names on the order" do
        expect(@order.product_names).to eq [@product_a,@product_b].map(&:name).join(",")
      end

      it "should return a blank string if the order has no associated line items" do
        @order.line_items = []
        expect(@order.product_names).to eq ""
      end
    end

    describe "#seller" do
      it "should return the seller associated with the first line item of the order" do
        expect(@order.selling_pharmacy).to eq @seller
      end

      it "should return nil if the order has no associated line items" do
        @order.line_items = []
        expect(@order.selling_pharmacy).to be_nil
      end
    end

    describe "#bought_by?" do
      before :all do
        @other_pharmacy = create_pharmacy
      end

      it "should return true if passed the pharmacy who is the buyer in the transaction" do
        expect(@order.bought_by?(@buyer)).to be_truthy
      end

      it "should return false if passed a pharmacy who is not the buyer in the transaction" do
        expect(@order.bought_by?(@other_pharmacy)).to be_falsey
        expect(@order.bought_by?(@seller)).to be_falsey
      end

      it "should return false if passed nil" do
        expect(@order.bought_by?(nil)).to be_falsey
      end
    end

    describe "#sold_by?" do
      before :all do
        @other_pharmacy = create_pharmacy
      end

      it "should return true if passed the pharmacy who is the buyer in the transaction" do
        expect(@order.sold_by?(@seller)).to be_truthy
      end

      it "should return false if passed a pharmacy who is not the buyer in the transaction" do
        expect(@order.sold_by?(@other_pharmacy)).to be_falsey
        expect(@order.sold_by?(@buyer)).to be_falsey
      end

      it "should return false if passed nil" do
        expect(@order.sold_by?(nil)).to be_falsey
      end
    end

    Marketplace::Order::State::valid_states.each do |state|
      other_state = (Marketplace::Order::State::valid_states - [state]).sample

      describe "##{state}?" do
        it "should return true when the state is '#{state}'" do
          @order.state = state
          expect(@order.send("#{state}?")).to be_truthy
        end

        it "should return false when the state is '#{other_state}'" do
          @order.state = other_state
          expect(@order.send("#{state}?")).to be_falsey
        end
      end
    end

    describe "#reference" do
      it "should return the renupharm_reference from the associated payment" do
        allow(@order).to receive(:payment).and_return(Marketplace::Payment.new(renupharm_reference: "Beetlejuice"))
        expect(@order.reference).to eq "Beetlejuice"
      end

      it "should return nil where no associated payment exists" do
        allow(@order).to receive(:payment).and_return(nil)
        expect(@order.reference).to be_nil
      end
    end

    describe "#next_state" do
      it "should return PLACED when current state is IN_PROGRESS" do
        @order.state = Marketplace::Order::State::IN_PROGRESS
        expect(@order.next_state).to eq Marketplace::Order::State::PLACED
      end

      it "should return DELIVERY_IN_PROGRESS when current state is PLACED" do
        @order.state = Marketplace::Order::State::PLACED
        expect(@order.next_state).to eq Marketplace::Order::State::DELIVERY_IN_PROGRESS
      end

      it "should return COMPLETED when current state is DELIVERY_IN_PROGRESS" do
        @order.state = Marketplace::Order::State::DELIVERY_IN_PROGRESS
        expect(@order.next_state).to eq Marketplace::Order::State::COMPLETED
      end

      it "should return nil when current state is COMPLETED" do
        @order.state = Marketplace::Order::State::COMPLETED
        expect(@order.next_state).to be_nil
      end
    end
  end
end
