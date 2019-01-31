require 'rails_helper'

describe Marketplace::ListingPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')

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

    %w(update destroy).each do |action|
      describe "##{action}?" do
        before :each do
          if action=='destroy'
            @listing = create_listing(product: @product)
          end
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ListingPolicy.new(@admin_user, @listing).send("#{action}?")).to be_truthy
        end

        it "should be true where user is an agent of the listing pharmacy" do
          expect(Marketplace::ListingPolicy.new(@user, @listing).send("#{action}?")).to be_truthy
        end

        it "should be false where user is not an agent for the listing pharmacy" do
          expect(Marketplace::ListingPolicy.new(@other_user, @listing).send("#{action}?")).to be_falsey
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
            expect(Marketplace::ListingPolicy.new(@admin_user, @listing).send("#{action}?")).to be_truthy
          end

          it "should be false where user is an agent for the listing pharmacy" do
            expect(Marketplace::ListingPolicy.new(@user, @listing).send("#{action}?")).to be_falsey
          end
        end
      end
    end
  end
end
