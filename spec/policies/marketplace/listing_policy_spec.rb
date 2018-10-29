require 'rails_helper'

describe Marketplace::ListingPolicy do
  include Factories::Marketplace

  before :all do
    @user = create_user(email: 'user@pharmacy.com')
    @other_user = create_user(email: 'user@otherpharmacy.com')
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
    @pharmacy = create_pharmacy.tap do |pharmacy|
      @agent = pharmacy.agents.create(user: @user, active: true)
    end
    @product = create_product(pharmacy: @pharmacy)
    @listing = create_listing(product: @product)
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::ListingPolicy.new(double("dummy user"), @listing) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where listing is active" do
        expect(Marketplace::ListingPolicy.new(@other_user, @listing).show?).to be_truthy
      end

      describe "where listing is inactive" do
        before :all do
          @listing.update_column(:active, false)
        end

        it "should be false" do
          expect(Marketplace::ListingPolicy.new(@other_user, @listing).show?).to be_falsey
        end

        it "should be true where user is an agent of the listing pharmacy" do
          expect(Marketplace::ListingPolicy.new(@user, @listing).show?).to be_truthy
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ListingPolicy.new(@admin_user, @listing).show?).to be_truthy
        end
      end
    end

    describe "#create?" do
      it "should be true where user is an admin" do
        expect(Marketplace::ListingPolicy.new(@admin_user, @product.listings.build).create?).to be_truthy
      end

      it "should be true where user is an agent of the listing pharmacy" do
        expect(Marketplace::ListingPolicy.new(@user, @product.listings.build).create?).to be_truthy
      end

      it "should be false where user is not an agent for the listing pharmacy" do
        expect(Marketplace::ListingPolicy.new(@other_user, @product.listings.build).create?).to be_falsey
      end

      describe "pharmacy is inactive" do
        before :all do
          @pharmacy.update_column(:active, false)
          [@pharmacy, @product, @listing].each(&:reload)
        end

        after :all do
          @pharmacy.update_column(:active, true)
          [@pharmacy, @product, @listing].each(&:reload)
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ListingPolicy.new(@admin_user, @product.listings.build).create?).to be_truthy
        end

        it "should be false where user is an agent for the pharmacy" do
          expect(Marketplace::ListingPolicy.new(@user, @product.listings.build).create?).to be_falsey
        end
      end
    end

    describe "#update?" do

      it "should be true where user is an admin" do
        expect(Marketplace::ListingPolicy.new(@admin_user, @listing).update?).to be_truthy
      end

      it "should be true where user is an agent of the listing pharmacy" do
        expect(Marketplace::ListingPolicy.new(@user, @listing).update?).to be_truthy
      end

      it "should be false where user is not an agent for the listing pharmacy" do
        expect(Marketplace::ListingPolicy.new(@other_user, @listing).update?).to be_falsey
      end

      describe "pharmacy is inactive" do
        before :all do
          @pharmacy.update_column(:active, false)
          [@pharmacy, @product, @listing].each(&:reload)
        end

        after :all do
          @pharmacy.update_column(:active, true)
          [@pharmacy, @product, @listing].each(&:reload)
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ListingPolicy.new(@admin_user, @listing).update?).to be_truthy
        end

        it "should be false where user is an agent for the listing pharmacy" do
          expect(Marketplace::ListingPolicy.new(@user, @listing).update?).to be_falsey
        end
      end
    end
  end
end
