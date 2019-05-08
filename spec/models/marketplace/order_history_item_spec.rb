require 'rails_helper'

describe Marketplace::OrderHistoryItem do
  include Factories::Marketplace

  [ :order,
    :user ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::OrderHistoryItem.new).to respond_to method
    end
  end

  before :all do
    @params = {
      order: create_order,
      user: create_user,
      from_state: Marketplace::Order::State::IN_PROGRESS,
      to_state: Marketplace::Order::State::PLACED,
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Marketplace::OrderHistoryItem.new(@params)).to be_valid
    end

    it "should be invalid when order is not supplied" do
      expect(Marketplace::OrderHistoryItem.new(@params.merge(order: nil))).not_to be_valid
    end

    it "should be invalid when user is not supplied" do
      expect(Marketplace::OrderHistoryItem.new(@params.merge(user: nil))).not_to be_valid
    end

    it "should be invalid when from_state is not supplied" do
      expect(Marketplace::OrderHistoryItem.new(@params.merge(from_state: nil))).not_to be_valid
    end

    it "should be invalid when to_state is not supplied" do
      expect(Marketplace::OrderHistoryItem.new(@params.merge(to_state: nil))).not_to be_valid
    end

    Marketplace::Order::State::valid_states.each do |valid_state|
      it "should be valid when from_state is a valid state" do
        expect(Marketplace::OrderHistoryItem.new(@params.merge(from_state: valid_state))).to be_valid
      end

      it "should be valid when to_state is a valid state" do
        expect(Marketplace::OrderHistoryItem.new(@params.merge(to_state: valid_state))).to be_valid
      end
    end

    ["waiting", "cancelled", "#*&"].each do |invalid_state|
      it "should not be valid when from_state is an invalid state" do
        expect(Marketplace::OrderHistoryItem.new(@params.merge(from_state: invalid_state))).not_to be_valid
      end

      it "should not be valid when to_state is a invalid state" do
        expect(Marketplace::OrderHistoryItem.new(@params.merge(to_state: invalid_state))).not_to be_valid
      end
    end
  end
end
