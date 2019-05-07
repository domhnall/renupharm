require 'rails_helper'

describe Marketplace::OrderPolicy do
  include Factories::Marketplace

  before :all do
    # Set up buying pharmacy
    @buying_pharmacy = create_pharmacy(name: 'Billy Buyer', email: 'billy@buyer.com')
    @buying_agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'willy@buyer.com'))
    @agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'silly@buyer.com'))

    # Set up selling pharmacy
    @selling_pharmacy = create_pharmacy(name: 'Sally Seller', email: 'sally@seller.com')
    @selling_agent = create_agent(pharmacy: @selling_pharmacy, user: create_user(email: 'mally@seller.com'))
    @listing = create_listing(pharmacy: @selling_pharmacy)
    @another_listing = create_listing(product: create_product(name: 'ABBA', pharmacy: @selling_pharmacy))

    # Other pharmacy agent
    @other_agent = create_agent(user: create_user(email: 'other@pharmacy.com'))

    # User records
    @agent_user = @agent.user.becomes(Users::Agent)
    @buying_agent_user = @buying_agent.user.becomes(Users::Agent)
    @selling_agent_user = @selling_agent.user.becomes(Users::Agent)
    @other_agent_user = @other_agent.user.becomes(Users::Agent)
    @admin_user = create_admin_user

    # Purchases
    @purchase = create_order(agent: @agent, listing: @listing, state: 'placed')
    @pending_purchase = create_order(agent: @buying_agent, listing: @another_listing)
    @another_purchase = create_order(agent: @buying_agent, listing: @another_listing, state: 'placed')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::OrderPolicy.new(double("dummy user"), @purchase) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "scope" do
    before :each do
    end

    it "should include orders purchased by the agents pharmacy" do
      expect(Marketplace::OrderPolicy::Scope.new(@agent_user, Marketplace::Order).resolve.map(&:id)).to match_array [@purchase, @another_purchase].map(&:id)
    end

    it "should include orders sold by the agents pharmacy" do
      expect(Marketplace::OrderPolicy::Scope.new(@selling_agent_user, Marketplace::Order).resolve.map(&:id)).to match_array [@purchase, @another_purchase].map(&:id)
    end

    it "should not include orders purchased by other pharmacies" do
      expect(Marketplace::OrderPolicy::Scope.new(@other_agent_user, Marketplace::Order).resolve.map(&:id)).to be_empty
    end

    it "should not include in-progress orders" do
      expect(Marketplace::OrderPolicy::Scope.new(@agent_user, Marketplace::Order).resolve.map(&:id)).not_to include @pending_purchase.id
      expect(Marketplace::OrderPolicy::Scope.new(@selling_agent_user, Marketplace::Order).resolve.map(&:id)).not_to include @pending_purchase.id
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where order has been purchased by the agents pharmacy" do
        expect(Marketplace::OrderPolicy.new(@agent_user, @purchase).show?).to be_truthy
      end

      it "should be true where order has been purchased by the agents pharmacy" do
        expect(Marketplace::OrderPolicy.new(@selling_agent_user, @purchase).show?).to be_truthy
      end

      it "should be false where order has not been bought or sold by the agents pharmacy" do
        expect(Marketplace::OrderPolicy.new(@other_agent_user, @purchase).show?).to be_falsey
      end
    end

    describe "#create?" do
      before :all do
        @order = create_order(agent: @agent, listing: @listing)
      end

      it "should be true where user owns the order" do
        expect(Marketplace::OrderPolicy.new(@agent.user, @order).create?).to be_truthy
      end

      it "should be false where user does not own the order" do
        expect(Marketplace::OrderPolicy.new(@other_agent.user, @order).create?).to be_falsey
      end
    end

    describe "#update?" do
      before :all do
        @order = create_order(agent: @agent, listing: @listing)
        @order.state = Marketplace::Order::State::valid_states.sample
      end

      it "should be true where the user is an admin" do
        expect(Marketplace::OrderPolicy.new(@admin_user, @order).update?).to be_truthy
      end

      it "should be false where user does not own the order" do
        @order.state = Marketplace::Order::State::IN_PROGRESS
        expect(Marketplace::OrderPolicy.new(@other_agent_user, @order).update?).to be_falsey
      end

      describe "where user owns the order" do
        it "should be true where the order is in 'in_progress' state" do
          @order.state = Marketplace::Order::State::IN_PROGRESS
          expect(Marketplace::OrderPolicy.new(@agent_user, @order).update?).to be_truthy
        end

        [ Marketplace::Order::State::PLACED,
          Marketplace::Order::State::COMPLETED ].each do |state|
          it "should be false where the order is in '#{state}' state" do
            @order.state = state
            expect(Marketplace::OrderPolicy.new(@agent_user, @order).update?).to be_falsey
          end
        end
      end

      describe "where user is agent for the buying pharmacy" do
        it "should be true where the order is in 'delivering' state" do
          @order.state = Marketplace::Order::State::DELIVERY_IN_PROGRESS
          expect(Marketplace::OrderPolicy.new(@buying_agent_user, @order).update?).to be_truthy
        end

        [ Marketplace::Order::State::IN_PROGRESS,
          Marketplace::Order::State::PLACED,
          Marketplace::Order::State::COMPLETED ].each do |state|
          it "should be false where the order is in '#{state}' state" do
            @order.state = state
            expect(Marketplace::OrderPolicy.new(@buying_agent_user, @order).update?).to be_falsey
          end
        end
      end

      describe "where user is agent for the selling pharmacy" do
        it "should be true where the order is in 'placed' state" do
          @order.state = Marketplace::Order::State::PLACED
          expect(Marketplace::OrderPolicy.new(@selling_agent_user, @order).update?).to be_truthy
        end

        [ Marketplace::Order::State::IN_PROGRESS,
          Marketplace::Order::State::DELIVERY_IN_PROGRESS,
          Marketplace::Order::State::COMPLETED ].each do |state|
          it "should be false where the order is in '#{state}' state" do
            @order.state = state
            expect(Marketplace::OrderPolicy.new(@selling_agent_user, @order).update?).to be_falsey
          end
        end
      end
    end
  end
end
