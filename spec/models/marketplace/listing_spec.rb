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
    :batch_number,
    :seller_note,
    :display_name,
    :product_name,
    :product_images,
    :product_form_name,
    :active_ingredient,
    :display_pack_size,
    :display_strength,
    :display_volume,
    :display_identifier,
    :display_channel_size,
    :selling_pharmacy,
    :pharmacy,
    :seller_id,
    :seller_name,
    :seller_address,
    :seller_telephone,
    :seller_email,
    :seller_image,
    :line_items ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Listing.new).to respond_to method
    end
  end

  before :all do
    @product = create_product
    @pharmacy = create_pharmacy
    @params = {
      product: @product,
      quantity: 2,
      price_cents: 8999,
      batch_number: "123456",
      seller_note: "Untouched boxes. Patient has moved on to a new strength.",
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

    [:quantity, :price_cents, :batch_number, :expiry].each do |attr|
      it "should not be valid when :#{attr} is not supplied" do
        expect(Marketplace::Listing.new(@params.merge(attr => nil))).not_to be_valid
      end
    end

    it "should be invalid if quantity is not greater than 0" do
      expect(Marketplace::Listing.new(@params.merge(quantity: 1))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(quantity: 0))).not_to be_valid
    end

    it "should be invalid if price_cents is not greater than 800" do
      expect(Marketplace::Listing.new(@params.merge(price_cents: 801))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(price_cents: 800))).not_to be_valid
    end

    it "should be invalid if price_cents is 500 EUR or greater" do
      expect(Marketplace::Listing.new(@params.merge(price_cents: 49999))).to be_valid
      expect(Marketplace::Listing.new(@params.merge(price_cents: 50000))).not_to be_valid
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

  describe "instance method" do
    describe "#display_price" do
      it "should return a String" do
        expect(Marketplace::Listing.new(price_cents: 9589).display_price).to be_a String
      end

      it "should return the rounded decimal price prefixed the EUR symbol" do
        expect(Marketplace::Listing.new(price_cents: 9589).display_price).to eq "???95.89"
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

    describe "#display_name" do
      it "should return a String" do
        expect(@pharmacy.listings.build(product: @product).display_name).to be_a String
      end

      it "should include the product name" do
        expect(@pharmacy.listings.build(product: @product).display_name).to include @product.name
      end

      it "should include the seller name" do
        expect(@pharmacy.listings.build(product: @product).display_name).to include @pharmacy.name
      end

      it "should reflect if the listing is inactive" do
        expect(@pharmacy.listings.build(product: @product, active: true).display_name).not_to include "(Inactive)"
        expect(@pharmacy.listings.build(product: @product, active: false).display_name).to include "(Inactive)"
      end
    end

    describe "#marketplace_pharmacy_id=" do
      before :all do
        @other_pharmacy = create_pharmacy(name: "Other pharmacy", email: "other@renupharm.ie")
        @generic_product = create_product({
          pharmacy: nil,
          name: "Vegetable Oil",
          pack_size: "1000 ml",
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

    describe "#can_delete?" do
      before :all do
        @listing = create_listing
      end

      it "should return true if the listing has no completed line items" do
        expect(@listing.can_delete?).to be_truthy
      end

      it "should return false if the listing has any completed line item" do
        create_order(listing: @listing, state: Marketplace::Order::State::COMPLETED)
        expect(@listing.can_delete?).to be_falsey
      end
    end
  end

  describe "destruction" do
    before :each do
      @listing_for_destroy = create_listing
    end

    it "should be possible to destroy a listing with IN_PROGRESS line items" do
      create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::IN_PROGRESS)
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
      expect(stuff = @listing_for_destroy.destroy).to be_truthy
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 0
    end

    it "should destroy the associated IN_PROGRESS line items" do
      item_1 = create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::IN_PROGRESS).line_items.first
      item_2 = create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::IN_PROGRESS).line_items.first
      expect(Marketplace::LineItem.where(id: [item_1.id, item_2.id]).count).to eq 2
      expect( @listing_for_destroy.destroy).to be_truthy
      expect(Marketplace::LineItem.where(id: [item_1.id, item_2.id]).count).to eq 0
    end

    it "should not be possible to destroy a listing with line items in a COMPLETED state" do
      create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::COMPLETED)
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
      expect(stuff = @listing_for_destroy.destroy).to be_falsey
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
    end

    it "should not be possible to destroy a listing with line items in a PLACED state" do
      create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::PLACED)
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
      expect(@listing_for_destroy.destroy).to be_falsey
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
    end

    it "should not be possible to destroy a listing with line items in a DELIVERY_IN_PROGRESS state" do
      create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::DELIVERY_IN_PROGRESS)
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
      expect(@listing_for_destroy.destroy).to be_falsey
      expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
    end
  end
end
