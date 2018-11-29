require 'rails_helper'

describe Marketplace::AgentPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy

    @agent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    )
    @user = @agent.user.becomes(Users::Agent)

    @other_agent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'other-user@pharmacy.com')
    )
    @other_user = @other_agent.user.becomes(Users::Agent)

    @other_pharmacy_agent = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    )
    @other_pharmacy_user = @other_pharmacy_agent.user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::AgentPolicy.new(double("dummy user"), @agent) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where agent is active" do
        expect(Marketplace::AgentPolicy.new(@other_pharmacy_user, @agent).show?).to be_truthy
      end

      describe "where agent is inactive" do
        before :all do
          @agent.update_column(:active, false)
        end

        it "should be false" do
          expect(Marketplace::AgentPolicy.new(@other_pharmacy_user, @agent).show?).to be_falsey
        end

        it "should be true where user is an agent of the same pharmacy" do
          expect(Marketplace::AgentPolicy.new(@user, @agent).show?).to be_truthy
        end

        it "should be true where user is an admin" do
          expect(Marketplace::AgentPolicy.new(@admin_user, @agent).show?).to be_truthy
        end
      end
    end

    describe "#create?" do
      it "should be false" do
        expect(Marketplace::AgentPolicy.new(@user, @pharmacy.agents.build).create?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::AgentPolicy.new(@admin_user, @pharmacy.agents.build).create?).to be_truthy
      end
    end

    describe "#update?" do
      it "should be false" do
        expect(Marketplace::AgentPolicy.new(@user, @other_agent).update?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::AgentPolicy.new(@admin_user, @other_agent).update?).to be_truthy
      end
    end
  end
end
