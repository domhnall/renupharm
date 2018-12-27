require 'rails_helper'

describe Marketplace::CreditCardPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy
    @credit_card = create_credit_card(pharmacy: @pharmacy)

    @superintendent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'super@pharmacy.com'),
      superintendent: true
    ).user.becomes(Users::Agent)

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    ).user.becomes(Users::Agent)


    @other_pharmacy_user = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    ).user.becomes(Users::Agent)

    @other_pharmacy_card = create_credit_card

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::CreditCardPolicy.new(double("dummy user"), @credit_card) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where user is an agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@user, @credit_card).show?).to be_truthy
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@other_pharmacy_user, @credit_card).show?).to be_falsey
      end

      it "should be true where user is an admin" do
        expect(Marketplace::CreditCardPolicy.new(@admin_user, @credit_card).show?).to be_truthy
      end
    end

    describe "#create?" do
      it "should be true where user is an admin" do
        expect(Marketplace::CreditCardPolicy.new(@admin_user, @pharmacy.credit_cards.build).create?).to be_truthy
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@other_pharmacy_user, @pharmacy.credit_cards.build).create?).to be_falsey
      end

      it "should be false where user is a regular agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@user, @pharmacy.credit_cards.build).create?).to be_falsey
      end

      it "should be true where user is the superintendent agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@superintendent, @pharmacy.credit_cards.build).create?).to be_truthy
      end
    end

    describe "#update?" do
      it "should be true where user is an admin" do
        expect(Marketplace::CreditCardPolicy.new(@admin_user, @credit_card).update?).to be_truthy
      end

      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@other_pharmacy_user, @credit_card).update?).to be_falsey
      end

      it "should be false where user is a regular agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@user, @credit_card).update?).to be_falsey
      end

      it "should be true where user is the superintendent agent of the pharmacy" do
        expect(Marketplace::CreditCardPolicy.new(@superintendent, @credit_card).update?).to be_truthy
      end
    end
  end
end
