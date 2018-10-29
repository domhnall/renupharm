require 'rails_helper'

describe Marketplace::AgentPolicy do
  include Factories::Marketplace

  before :all do
    @user = create_user(email: 'user@pharmacy.com')
    @other_user = create_user(email: 'other_user@pharmacy.com')
    @other_pharmacy_user = create_user(email: 'user@otherpharmacy.com')
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
    @pharmacy = create_pharmacy.tap do |pharmacy|
      @agent = pharmacy.agents.create(user: @user, active: true)
      @other_agent = pharmacy.agents.create(user: @other_user, active: true)
    end
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
