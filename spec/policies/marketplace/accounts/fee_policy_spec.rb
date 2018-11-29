require 'rails_helper'

describe Marketplace::Accounts::FeePolicy do
  include Factories::Marketplace

  before :all do
    @payment = create_payment.tap do |payment|
      @fee = payment.fees.create(amount_cents: 750, currency_code: "EUR")
    end
    @buying_user  = @payment.buying_pharmacy.agents.first.user.becomes(Users::Agent)
    @selling_user = @payment.selling_pharmacy.agents.first.user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::Accounts::FeePolicy.new(double("dummy user"), @fee) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be false where user is the buyer" do
        expect(Marketplace::Accounts::FeePolicy.new(@buying_user, @fee).show?).to be_falsey
      end

      it "should be true where user is agent for the selling pharmacy" do
        expect(Marketplace::Accounts::FeePolicy.new(@selling_user, @fee).show?).to be_truthy
      end

      it "should be true where user is a renupharm admin" do
        expect(Marketplace::Accounts::FeePolicy.new(@admin_user, @fee).show?).to be_truthy
      end
    end

    describe "#create?" do
      it "should be false where user is not a renupharm admin" do
        expect(Marketplace::Accounts::FeePolicy.new(@selling_user, @fee).create?).to be_falsey
      end

      it "should be true where user is a renupharm admin" do
        expect(Marketplace::Accounts::FeePolicy.new(@admin_user, @fee).create?).to be_truthy
      end
    end

    describe "#update?" do
      it "should be false where user is not a renupharm admin" do
        expect(Marketplace::Accounts::FeePolicy.new(@selling_user, @fee).update?).to be_falsey
      end

      it "should be true where user is a renupharm admin" do
        expect(Marketplace::Accounts::FeePolicy.new(@admin_user, @fee).update?).to be_truthy
      end
    end
  end
end
