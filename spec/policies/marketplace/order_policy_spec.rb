require 'rails_helper'

describe Marketplace::OrderPolicy do
  include Factories::Marketplace

  before :all do
    @buying_pharmacy = create_pharmacy(name: 'Billy Buyer', email: 'billy@buyer.com')
    @agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'silly@buyer.com'))

    @selling_pharmacy = create_pharmacy(name: 'Sally Seller', email: 'sally@seller.com')
    @listing = create_listing(pharmacy: @selling_pharmacy)

    @order = create_order(agent: @agent, listing: @listing)
    @other_agent = create_agent(user: create_user(email: 'other@pharmacy.com'))
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::OrderPolicy.new(double("dummy user"), @order) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where user owns the order" do
        expect(Marketplace::OrderPolicy.new(@agent.user, @order).show?).to be_truthy
      end

      it "should be false where user does not own the order" do
        expect(Marketplace::OrderPolicy.new(@other_agent.user, @order).show?).to be_falsey
      end
    end

    describe "#create?" do
      it "should be true where user owns the order" do
        expect(Marketplace::OrderPolicy.new(@agent.user, @order).create?).to be_truthy
      end

      it "should be false where user does not own the order" do
        expect(Marketplace::OrderPolicy.new(@other_agent.user, @order).create?).to be_falsey
      end
    end

    describe "#update?" do
      it "should be true where user owns the order" do
        expect(Marketplace::OrderPolicy.new(@agent.user, @order).update?).to be_truthy
      end

      it "should be false where user does not own the order" do
        expect(Marketplace::OrderPolicy.new(@other_agent.user, @order).update?).to be_falsey
      end
    end
  end
end
