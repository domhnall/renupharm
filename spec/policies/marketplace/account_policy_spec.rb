require 'rails_helper'

describe Marketplace::AccountPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy
    @account = @pharmacy.account

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    ).user.becomes(Users::Agent)


    @other_pharmacy_user = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::AccountPolicy.new(double("dummy user"), @account) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where user is an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@user, @account).show?).to be_truthy
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@other_pharmacy_user, @account).show?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::AccountPolicy.new(@admin_user, @account).show?).to be_truthy
      end
    end

    describe "#create?" do
      it "should be false where user is an admin" do
        expect(Marketplace::AccountPolicy.new(@admin_user, @account).create?).to be_falsey
      end

      it "should be false where user is an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@user, @account).create?).to be_falsey
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@other_pharmacy_user, @account).create?).to be_falsey
      end
    end

    describe "#update?" do
      it "should be false where user is an admin" do
        expect(Marketplace::AccountPolicy.new(@admin_user, @account).update?).to be_falsey
      end

      it "should be false where user is an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@user, @account).update?).to be_falsey
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::AccountPolicy.new(@other_pharmacy_user, @account).update?).to be_falsey
      end
    end
  end
end
