require 'rails_helper'

describe Marketplace::PharmacyPolicy do
  include Factories::Marketplace

  before :all do
    @user = create_user(email: 'user@pharmacy.com')
    @other_user = create_user(email: 'user@otherpharmacy.com')
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
    @pharmacy = create_pharmacy.tap do |pharmacy|
      pharmacy.agents.create(user: @user)
    end
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::PharmacyPolicy.new(double("dummy user"), @pharmacy) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should return true for any active pharmacy" do
        expect(Marketplace::PharmacyPolicy.new(@other_user, @pharmacy).show?).to be_truthy
      end

      it "should return true for any inactive pharmacy if user is an agent of the pharmacy" do
        @pharmacy.update_column(:active, false)
        expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).show?).to be_truthy
      end

      describe "inactive pharmacy" do
        before :each do
          @pharmacy.update_column(:active, false)
        end

        it "should return false for a user not associated with the pharmacy" do
          expect(Marketplace::PharmacyPolicy.new(@other_user, @pharmacy).show?).to be_falsey
        end

        it "should return true for if user is an agent of the pharmacy" do
          expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).show?).to be_truthy
        end

        it "should return true if user is an admin" do
          expect(Marketplace::PharmacyPolicy.new(@admin_user, @pharmacy).show?).to be_truthy
        end
      end
    end

    describe "#update?" do
      before :all do
        @pharmacy.reload
      end

      it "should return true if user is an admin" do
        expect(Marketplace::PharmacyPolicy.new(@admin_user, @pharmacy).update?).to be_truthy
      end

      it "should return false if user is not an agent of the pharmacy" do
        expect(Marketplace::PharmacyPolicy.new(@other_user, @pharmacy).update?).to be_falsey
      end

      it "should return true if user is an agent of the pharmacy" do
        expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).update?).to be_truthy
      end

      it "should return false if user is an agent of the pharmacy, but pharamcy is inactive" do
        expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).update?).to be_truthy
        @pharmacy.update_column(:active, false)
        @pharmacy.reload
        expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).update?).to be_falsey
      end
    end

    describe "#create?" do
      it "should return true if user is an admin" do
        expect(Marketplace::PharmacyPolicy.new(@admin_user, @pharmacy).create?).to be_truthy
      end

      it "should return false if user is not an admin" do
        expect(Marketplace::PharmacyPolicy.new(@user, @pharmacy).create?).to be_falsey
      end
    end
  end
end
