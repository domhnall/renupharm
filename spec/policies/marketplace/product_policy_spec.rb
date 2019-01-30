require 'rails_helper'

describe Marketplace::ProductPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy.tap do |pharmacy|
      pharmacy.products << (@product = create_product(pharmacy: pharmacy))
    end.reload

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: create_pharmacy(name: "McGrew's", email: "jim@mcgrew.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie').becomes(Users::Admin)
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

    %w(update destroy).each do |action|
      describe "##{action}?" do
        it "should be false where user is not an agent of the pharmacy" do
          expect(Marketplace::ProductPolicy.new(@other_user, @product).send("#{action}?")).to be_falsey
        end

        it "should be true where user is an agent of the pharmacy" do
          expect(Marketplace::ProductPolicy.new(@user, @product).send("#{action}?")).to be_truthy
        end

        it "should be true where user is an admin" do
          expect(Marketplace::ProductPolicy.new(@admin_user, @product).send("#{action}?")).to be_truthy
        end
      end
    end
  end
end
