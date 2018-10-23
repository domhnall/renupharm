require 'rails_helper'

describe Marketplace::Order do
  include Factories::Base
  include Factories::Marketplace

  [ :state,
    :agent,
    :line_items ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Order.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @pharmacy = create_pharmacy
      @agent = create_agent(pharmacy: @pharmacy)
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
end
