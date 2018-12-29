require 'rails_helper'

describe Marketplace::PurchasePolicy do
  include Factories::Marketplace

  before :all do
    @buying_pharmacy = create_pharmacy(name: 'Billy Buyer', email: 'billy@buyer.com')
    @buying_agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'willy@buyer.com'))
    @agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'silly@buyer.com'))

    @selling_pharmacy = create_pharmacy(name: 'Sally Seller', email: 'sally@seller.com')
    @listing = create_listing(pharmacy: @selling_pharmacy)

    @purchase = create_order(agent: @buying_agent, listing: @listing, state: 'placed').becomes(Marketplace::Purchase)
    @other_agent = create_agent(user: create_user(email: 'other@pharmacy.com'))
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::PurchasePolicy.new(double("dummy user"), @purchase) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "scope" do
    before :each do
      @agent_user = @agent.user.becomes(Users::Agent)
      @other_agent_user = @other_agent.becomes(Users::Agent)
      @another_listing = create_listing(product: create_product(name: 'ABBA', pharmacy: @selling_pharmacy))
      @pending_purchase = create_order(agent: @buying_agent, listing: @another_listing).becomes(Marketplace::Purchase)
      @another_purchase = create_order(agent: @buying_agent, listing: @another_listing, state: 'placed').becomes(Marketplace::Purchase)
    end

    it "should include orders purchased by the agents pharmacy" do
      expect(Marketplace::PurchasePolicy::Scope.new(@agent_user, Marketplace::Purchase).resolve.map(&:id)).to match_array [@purchase, @another_purchase].map(&:id)
    end

    it "should not include orders purchased by other pharmacies" do
      expect(Marketplace::PurchasePolicy::Scope.new(@other_agent_user, Marketplace::Purchase).resolve.map(&:id)).to be_empty
    end

    it "should not include in-progress orders" do
      expect(Marketplace::PurchasePolicy::Scope.new(@agent_user, Marketplace::Purchase).resolve.map(&:id)).not_to include @pending_purchase.id
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where user owns the order" do
        expect(Marketplace::PurchasePolicy.new(@buying_agent.user.becomes(Users::Agent), @purchase).show?).to be_truthy
      end

      it "should be true where user is agent for the same pharmacy as purchaser" do
        expect(Marketplace::PurchasePolicy.new(@agent.user.becomes(Users::Agent), @purchase).show?).to be_truthy
      end

      it "should be false where user does not belong to same pharmacy as purchaser" do
        expect(Marketplace::PurchasePolicy.new(@other_agent.user.becomes(Users::Agent), @purchase).show?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::PurchasePolicy.new(@admin_user, @purchasej).show?).to be_truthy
      end
    end

    describe "#index?" do
      it "should be true" do
        expect(Marketplace::PurchasePolicy.new(@other_agent.user.becomes(Users::Agent), @purchase).index?).to be_truthy
      end
    end
  end
end
