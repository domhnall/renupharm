require 'rails_helper'

describe Marketplace::Pharmacy do
  include Factories::Marketplace

  before :all do
    @params = {
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone: "(01) 283 7188",
      email: "grainne@sandymount.ie"
    }
  end

  [ :name,
    :description,
    :email,
    :address_1,
    :address_2,
    :address_3,
    :telephone,
    :fax,
    :image,
    :account,
    :agents,
    :products,
    :listings,
    :bank_account,
    :seller_payouts,
    :address,
    :bank_name,
    :bic,
    :iban,
    :default_card ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Pharmacy.new).to respond_to method
    end
  end

  describe "instantiation" do
    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Pharmacy.new(@params)).to be_valid
    end

    it "should be valid when :address_2 is not supplied" do
      expect(Marketplace::Pharmacy.new(@params.merge(address_2: nil))).to be_valid
    end


    [ :name,
      :address_1,
      :address_3,
      :telephone,
      :email ].each do |attr|
      it "should be invalid when :#{attr} is not supplied" do
        @params.except(attr)
        expect(Marketplace::Pharmacy.new(@params.except(attr))).not_to be_valid
      end
    end

    [ :name,
      :address_1,
      :address_2,
      :address_3 ].each do |attr|

      it "should be invalid when :#{attr} exceeds length of 255 characters" do
        params = @params.dup.tap do |hash|
          hash[attr] = "A"*255
        end
        expect(Marketplace::Pharmacy.new(params)).to be_valid
        params[attr] = "A"*256
        expect(Marketplace::Pharmacy.new(params)).not_to be_valid
      end

      it "should be invalid when :#{attr} has length of less than 4 characters" do
        params = @params.dup.tap do |hash|
          hash[attr] = "A"*3
        end
        expect(Marketplace::Pharmacy.new(params)).to be_valid
        params[attr] = "A"*2
        expect(Marketplace::Pharmacy.new(params)).not_to be_valid
      end
    end

    it "should be invalid when :email exceeds length of 254 characters" do
      valid_email = "A"*242 + "@example.com"
      expect(Marketplace::Pharmacy.new(@params.merge(email: valid_email))).to be_valid
      invalid_email = "A"*243 + "@example.com"
      expect(Marketplace::Pharmacy.new(@params.merge(email: invalid_email))).not_to be_valid
    end

    it "should be invalid when :telephone exceeds length of 16 characters" do
      expect(Marketplace::Pharmacy.new(@params.merge(telephone: "+353 12345678901"))).to be_valid
      expect(Marketplace::Pharmacy.new(@params.merge(telephone: "+353 123456789012"))).not_to be_valid
    end

    it "should be invalid when :telephone has length of less than 11 characters" do
      expect(Marketplace::Pharmacy.new(@params.merge(telephone: "+353 123456"))).to be_valid
      expect(Marketplace::Pharmacy.new(@params.merge(telephone: "+353 12345"))).not_to be_valid
    end

    it "should be invalid when a pharmacy with the same email already exists" do
      expect(existing_contact = Marketplace::Pharmacy.new(@params)).to be_valid
      existing_contact.save!
      expect(Marketplace::Pharmacy.new(@params.merge(name: "Alternative"))).not_to be_valid
    end

    it "should be invalid when a pharmacy with the same name already exists" do
      expect(existing_contact = Marketplace::Pharmacy.new(@params)).to be_valid
      existing_contact.save!
      expect(Marketplace::Pharmacy.new(@params.merge(email: "alt@sandymount.ie"))).not_to be_valid
    end

    it "should be valid when both email and name are unique" do
      expect(existing_contact = Marketplace::Pharmacy.new(@params)).to be_valid
      existing_contact.save!
      expect(Marketplace::Pharmacy.new(@params.merge(name: "Alternative", email: "alt@sandymount.ie"))).to be_valid
    end
  end

  describe "scope" do
    before :all do
      @harrietts = create_pharmacy({
        name: "Harriett's Potion Shop",
        email: "harry@harrietts.com",
        active: true
      })
      @mcardles = create_pharmacy({
        name: "McArdle's",
        email: "harry@mcardles.com",
        active: true
      })
    end

    describe "#active" do
      it "should include all pharmacies where :active is true" do
        expect(Marketplace::Pharmacy.active.map(&:email)).to match_array %w(harry@harrietts.com harry@mcardles.com)
      end

      it "should exclude pharmacies where :active is false" do
        @mcardles.update_column(:active, false)
        expect(Marketplace::Pharmacy.active.map(&:email)).to include "harry@harrietts.com"
        expect(Marketplace::Pharmacy.active.map(&:email)).not_to include "harry@mcardles.com"
      end
    end
  end

  describe "instance method" do
    describe "#account" do
      it "should return a Marketplace::Account for the pharamcy" do
        pharmacy = Marketplace::Pharmacy.new(@params)
        expect(pharmacy.account).to be_a Marketplace::Account
        expect(pharmacy.account.pharmacy).to eq pharmacy
      end
    end

    describe "#address" do
      it "should return a comma separated list of the address components" do
        expect(Marketplace::Pharmacy.new(@params).address).to eq "1a Sandymount Green, Dublin 4, Irishtown, Dublin 4"
      end

      it "should return strip out any nil components without leaving commas" do
        expect(Marketplace::Pharmacy.new(@params.merge(address_2: "")).address).to eq "1a Sandymount Green, Dublin 4"
      end
    end

    describe "#default_card" do
      before :all do
        @pharmacy = Marketplace::Pharmacy.create!(@params)
        @default_card = create_credit_card(pharmacy: @pharmacy, default: true)
        @other_card = create_credit_card(pharmacy: @pharmacy, default: false)
      end

      it "should return the first default card for the pharmacy" do
        expect(@pharmacy.reload.default_card.id).to eq @default_card.id
      end

      it "should return the last created card for the pharmacy if no default set" do
        @default_card.update_column(:default, false)
        expect(@pharmacy.reload.default_card.id).to eq @other_card.id
      end
    end
  end
end
