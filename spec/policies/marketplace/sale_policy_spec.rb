require 'rails_helper'

describe Marketplace::SalePolicy do
  include Factories::Marketplace

  before :all do
    @buying_pharmacy = create_pharmacy(name: 'Billy Buyer', email: 'billy@buyer.com')
    @buying_agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'willy@buyer.com'))

    @selling_pharmacy = create_pharmacy(name: 'Sally Seller', email: 'sally@seller.com')
    @selling_agent = create_agent(pharmacy: @selling_pharmacy, user: create_user(email: 'bally@seller.com'))
    @listing = create_listing(pharmacy: @selling_pharmacy)

    @sale = create_order(agent: @buying_agent, listing: @listing, state: 'placed').becomes(Marketplace::Sale)
    @other_agent = create_agent(user: create_user(email: 'other@pharmacy.com'))
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::SalePolicy.new(double("dummy user"), @sale) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "scope" do
    before :each do
      @agent_user = @selling_agent.user.becomes(Users::Agent)
      @other_agent_user = @other_agent.becomes(Users::Agent)
      @another_listing = create_listing(product: create_product(name: 'ABBA', pharmacy: @selling_pharmacy))
      @pending_sale = create_order(agent: @buying_agent, listing: @another_listing).becomes(Marketplace::Sale)
      @another_sale = create_order(agent: @buying_agent, listing: @another_listing, state: 'placed').becomes(Marketplace::Sale)
    end

    it "should include orders sold by the agents pharmacy" do
      expect(Marketplace::SalePolicy::Scope.new(@agent_user, Marketplace::Sale).resolve.map(&:id)).to match_array [@sale, @another_sale].map(&:id)
    end

    it "should not include orders purchased by other pharmacies" do
      expect(Marketplace::SalePolicy::Scope.new(@other_agent_user, Marketplace::Sale).resolve.map(&:id)).to be_empty
    end

    it "should not include in-progress orders" do
      expect(Marketplace::SalePolicy::Scope.new(@agent_user, Marketplace::Sale).resolve.map(&:id)).not_to include @pending_sale.id
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where user is agent for the selling pharmacy" do
        expect(Marketplace::SalePolicy.new(@selling_agent.user.becomes(Users::Agent), @sale).show?).to be_truthy
      end

      it "should be false where user does not belong to the selling pharmacy" do
        expect(Marketplace::SalePolicy.new(@other_agent.user.becomes(Users::Agent), @sale).show?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::SalePolicy.new(@admin_user, @sale).show?).to be_truthy
      end
    end

    describe "#index?" do
      it "should be true" do
        expect(Marketplace::SalePolicy.new(@other_agent.user.becomes(Users::Agent), @sale).index?).to be_truthy
      end
    end
  end
end
