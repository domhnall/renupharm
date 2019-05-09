require 'rails_helper'

describe Marketplace::OrderFeedbackPolicy do
  include Factories::Marketplace

  before :all do
    @buying_pharmacy = create_pharmacy(name: 'Billy Buyer', email: 'billy@buyer.com')
    @agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'silly@buyer.com'))
    @buying_agent = create_agent(pharmacy: @buying_pharmacy, user: create_user(email: 'willy@buyer.com'))
    @other_agent = create_agent(user: create_user(email: 'other@pharmacy.com'))

    @agent_user = @agent.user.becomes(Users::Agent)
    @buying_agent_user = @buying_agent.user.becomes(Users::Agent)
    @other_agent_user = @other_agent.user.becomes(Users::Agent)

    @order = create_order(agent: @agent, state: 'completed')
    @placed_order = create_order(agent: @agent, state: 'placed')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::OrderFeedbackPolicy.new(double("dummy user"), "Anything") }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      describe "where the order feedback has been persisted" do
        before :each do
          @order_feedback = @order.create_feedback(rating: 3, message: "This was a satisfactory purchase", user: @agent_user)
        end

        it "should be true where user is the purchasing agent" do
          expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @order_feedback).show?).to be_truthy
        end

        it "should be true where user is an agent of the buying pharmacy" do
          expect(Marketplace::OrderFeedbackPolicy.new(@buying_agent_user, @order_feedback).show?).to be_truthy
        end

        it "should be true where user is not an agent of the buying pharmacy" do
          expect(Marketplace::OrderFeedbackPolicy.new(@other_agent_user, @order_feedback).show?).to be_truthy
        end
      end

      describe "where order feedback not yet persisted" do
        before :each do
          @order_feedback = @order.build_feedback(rating: 3, message: "This was a satisfactory purchase")
        end

        it "should be true where user is the purchasing agent" do
          expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @order_feedback).show?).to be_truthy
        end

        it "should be true where user is an agent of the buying pharmacy" do
          expect(Marketplace::OrderFeedbackPolicy.new(@buying_agent_user, @order_feedback).show?).to be_truthy
        end

        it "should be false where user is not an agent of the buying pharmacy" do
          expect(Marketplace::OrderFeedbackPolicy.new(@other_agent_user, @order_feedback).show?).to be_falsey
        end
      end
    end

    describe "#create?" do
      before :each do
        @order_feedback = @order.build_feedback(rating: 4, message: "Really happy with this one")
        @placed_order_feedback = @placed_order.build_feedback(rating: 4, message: "Not complete, but still happy")
      end

      it "should be true where user is the purchasing agent" do
        expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @order_feedback).create?).to be_truthy
      end

      it "should be true where user is an agent of the buying pharmacy" do
        expect(Marketplace::OrderFeedbackPolicy.new(@buying_agent_user, @order_feedback).create?).to be_truthy
      end

      it "should be false where user is not an agent of the buying pharmacy" do
        expect(Marketplace::OrderFeedbackPolicy.new(@other_agent_user, @order_feedback).create?).to be_falsey
      end

      it "should be false where order is not in completed state" do
        expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @placed_order_feedback).create?).to be_falsey
      end
    end

    describe "#update?" do
      before :each do
        @order_feedback = @order.create_feedback(rating: 4, message: "Really happy with this one", user: @buying_agent_user)
      end

      it "should be true where user is the original author of the feedback" do
        expect(Marketplace::OrderFeedbackPolicy.new(@buying_agent_user, @order_feedback).update?).to be_truthy
      end

      it "should be false where user is not the original author of the feedback" do
        expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @order_feedback).update?).to be_falsey
      end

      it "should be false where user is not an agent of the buying pharmacy" do
        expect(Marketplace::OrderFeedbackPolicy.new(@other_agent_user, @order_feedback).update?).to be_falsey
      end
    end

    describe "#destroy?" do
      before :each do
        @order_feedback = @order.create_feedback(rating: 4, message: "Really happy with this one", user: @buying_agent_user)
      end

      it "should be true where user is the original author of the feedback" do
        expect(Marketplace::OrderFeedbackPolicy.new(@buying_agent_user, @order_feedback).destroy?).to be_truthy
      end

      it "should be false where user is not the original author of the feedback" do
        expect(Marketplace::OrderFeedbackPolicy.new(@agent_user, @order_feedback).destroy?).to be_falsey
      end

      it "should be false where user is not an agent of the buying pharmacy" do
        expect(Marketplace::OrderFeedbackPolicy.new(@other_agent_user, @order_feedback).destroy?).to be_falsey
      end
    end
  end
end
