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
    :seller_name,
    :seller_address,
    :seller_telephone,
    :seller_email,
    :seller_image ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Listing.new).to respond_to method
    end
  end

  describe "instantiation" do
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
  end
end
