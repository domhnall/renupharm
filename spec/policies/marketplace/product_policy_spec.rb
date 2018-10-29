require 'rails_helper'

describe Marketplace::ProductPolicy do
  include Factories::Marketplace

  before :all do
    @user = create_user(email: 'user@pharmacy.com')
    @other_user = create_user(email: 'user@otherpharmacy.com')
    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
    @pharmacy = create_pharmacy.tap do |pharmacy|
      pharmacy.agents.create(user: @user)
      pharmacy.products << (@product = create_product(pharmacy: pharmacy))
    end.reload
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::ProductPolicy.new(double("dummy user"), @product) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    describe "#show?" do
      it "should be true where product is active" do
        expect(Marketplace::ProductPolicy.new(@other_user, @product).show?).to be_truthy
      end

      describe "where product is inactive" do
        before :all do
          @product.update_column(:active, false)
        end

        it "should be false" do
          expect(Marketplace::ProductPolicy.new(@other_user, @product).show?).to be_falsey
        end

        it "should be true where user is an agent of the same pharmacy" do
          expect(Marketplace::ProductPolicy.new(@user, @product).show?).to be_truthy
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ProductPolicy.new(@admin_user, @product).show?).to be_truthy
        end
      end
    end

    describe "#create?" do
      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::ProductPolicy.new(@other_user, @pharmacy.products.build).create?).to be_falsey
      end

      it "should be true where user is an agent of the pharmacy" do
        expect(Marketplace::ProductPolicy.new(@user, @pharmacy.products.build).create?).to be_truthy
      end

      it "should be true where user is an admin" do
        expect(Marketplace::ProductPolicy.new(@admin_user, @pharmacy.products.build).create?).to be_truthy
      end
    end

    describe "#update?" do
      it "should be false where user is not an agent of the pharmacy" do
        expect(Marketplace::ProductPolicy.new(@other_user, @product).update?).to be_falsey
      end

      it "should be true where user is an agent of the pharmacy" do
        expect(Marketplace::ProductPolicy.new(@user, @product).update?).to be_truthy
      end

      it "should be true where user is an admin" do
        expect(Marketplace::ProductPolicy.new(@admin_user, @product).update?).to be_truthy
      end
    end
  end
end
