require 'rails_helper'

describe Marketplace::Listing do
  include Factories::Base
  include Factories::Marketplace

  [ :quantity,
    :price_cents,
    :expiry,
    :product,
    :active,
    :acceptable_expiry?,
    :product_name,
    :product_description,
    :product_unit_size,
    :product_images,
    :selling_pharmacy,
    :pharmacy,
    :seller_name,
    :seller_address,
    :seller_telephone,
    :seller_email,
    :seller_image ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Listing.new).to respond_to method
    end
  end

  before :all do
    @product = create_product
    @params = {
      product: @product,
      quantity: 2,
      price_cents: 8999,
      expiry: Date.today+90.days,
      active: true
    }
  end

  describe "instantiation" do
    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Listing.new(@params)).to be_valid
    end

    it "should not be valid when :product is not supplied" do
      expect(Marketplace::Listing.new(@params.merge(product: nil, marketplace_product_id: nil))).not_to be_valid
    end

    [:quantity, :price_cents, :expiry].each do |attr|
      it "should not be valid when :#{attr} is not supplied" do
        expect(Marketplace::Listing.new(@params.merge(attr => nil))).not_to be_valid
      end
    end

    it "should be invalid if quantity is not greater than 0" do
      expect(Marketplace::Listing.new(@params.merge(quantity: 1))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(quantity: 0))).not_to be_valid
    end

    it "should be invalid if price_cents is not greater than 7999" do
      expect(Marketplace::Listing.new(@params.merge(price_cents: 8000))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(price_cents: 7999))).not_to be_valid
    end

    it "should be invalid if expiry is within the next week" do
      expect(Marketplace::Listing.new(@params.merge(expiry: Date.today+7.days))).not_to be_valid
      expect(Marketplace::Listing.new(@params.merge(expiry: Date.today-7.days))).not_to be_valid
      expect(Marketplace::Listing.new(@params.merge(expiry: Date.today+8.days))).to be_valid
    end

    it "should be valid if listing marked as inactive, regardless of expiry" do
      expect(Marketplace::Listing.new(@params.merge(active: false, expiry: Date.today+2.days))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(active: false, expiry: Date.today-28.days))).to be_valid
    end

    it "should automatically assign the marketplace_pharmacy_id to match the ID on the product" do
      expect(Marketplace::Listing.new(@params).marketplace_pharmacy_id).to eq @product.marketplace_pharmacy_id
    end
  end

  describe "class method" do
    describe "#currency_symbol" do
      it "should return €" do
        expect(Marketplace::Listing::currency_symbol).to eq "€"
      end
    end
  end

  describe "instance method" do
    describe "#display_price" do
      it "should return a String" do
        expect(Marketplace::Listing.new(price_cents: 9589).display_price).to be_a String
      end

      it "should return the rounded decimal price prefixed the EUR symbol" do
        expect(Marketplace::Listing.new(price_cents: 9589).display_price).to eq "€95.89"
      end
    end

    describe "#price_major" do
      it "should return a String" do
        expect(Marketplace::Listing.new(price_cents: 9589).price_major).to be_a String
      end

      it "should return the integer EUR component of the price" do
        expect(Marketplace::Listing.new(price_cents: 9589).price_major).to eq "95"
      end
    end

    describe "#price_minor" do
      it "should return a String" do
        expect(Marketplace::Listing.new(price_cents: 9589).price_minor).to be_a String
      end

      it "should return the integer cent component of the price" do
        expect(Marketplace::Listing.new(price_cents: 9589).price_minor).to eq "89"
      end
    end

    describe "#marketplace_pharmacy_id=" do
      before :all do
        @other_pharmacy = create_pharmacy(name: "Other pharmacy", email: "other@renupharm.ie")
        @generic_product = Marketplace::Product.create!({
          name: "Vegetable Oil",
          unit_size: "1000 ml",
          description: "Excellent for cooking"
        })
      end

      it "should not permit the the marketplace_pharmacy_id to be altered if pharmacy ID exits on the product" do
        listing = Marketplace::Listing.new(@params)
        expect(listing.marketplace_pharmacy_id).to eq @product.marketplace_pharmacy_id
        listing.marketplace_pharmacy_id = @other_pharmacy.id
        expect(listing.marketplace_pharmacy_id).to eq @product.marketplace_pharmacy_id
      end

      it "should permit the marketplace_pharmacy_id ot be altered if the pharmacy ID is nil on the product" do
        listing = Marketplace::Listing.new(@params.merge(product: @generic_product))
        expect(listing.marketplace_pharmacy_id).to be_nil
        listing.marketplace_pharmacy_id = @other_pharmacy.id
        expect(listing.marketplace_pharmacy_id).to eq @other_pharmacy.id
      end
    end
  end
end
