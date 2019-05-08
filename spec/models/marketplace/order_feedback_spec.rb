require 'rails_helper'

describe Marketplace::OrderFeedback do
  include Factories::Marketplace

  [ :order,
    :user,
    :message,
    :rating ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::OrderFeedback.new).to respond_to method
    end
  end

  before :all do
    @params = {
      order: create_order,
      user: create_user,
      message: "Arrived promptly precisely as described",
      rating: 4
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Marketplace::OrderFeedback.new(@params)).to be_valid
    end

    it "should be invalid when order is not supplied" do
      expect(Marketplace::OrderFeedback.new(@params.merge(order: nil))).not_to be_valid
    end

    it "should be invalid when user is not supplied" do
      expect(Marketplace::OrderFeedback.new(@params.merge(user: nil))).not_to be_valid
    end

    it "should be invalid when rating is not supplied" do
      expect(Marketplace::OrderFeedback.new(@params.merge(rating: nil))).not_to be_valid
    end

    it "should be valid when message is not supplied" do
      expect(Marketplace::OrderFeedback.new(@params.merge(message: nil))).to be_valid
      expect(Marketplace::OrderFeedback.new(@params.merge(message: ""))).to be_valid
    end

    it "should be invalid when message exceeds 1000 characters" do
      expect(Marketplace::OrderFeedback.new(@params.merge(message: "a"*999))).to be_valid
      expect(Marketplace::OrderFeedback.new(@params.merge(message: "a"*1000))).to be_valid
      expect(Marketplace::OrderFeedback.new(@params.merge(message: "a"*1001))).not_to be_valid
    end
  end
end
