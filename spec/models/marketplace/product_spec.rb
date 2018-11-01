require 'rails_helper'

describe Marketplace::Product do
  include Factories::Base
  include Factories::Marketplace

  [ :name,
    :description,
    :unit_size,
    :pharmacy,
    :listings ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Product.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @pharmacy = create_pharmacy
      @params = {
        pharmacy: @pharmacy,
        name: "Paracetomol",
        description: "Some description",
        unit_size: "40 capsules",
        active: true
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Product.new(@params)).to be_valid
    end

    it "should be valid when :pharmacy is not supplied" do
      expect(Marketplace::Product.new(@params.merge(pharmacy: nil, marketplace_pharmacy_id: nil))).to be_valid
    end

    it "should be invalid when :name is not supplied" do
      expect(Marketplace::Product.new(@params.merge(name: nil))).not_to be_valid
    end

    it "should be invalid when :name is not supplied" do
      expect(Marketplace::Product.new(@params.merge(name: nil))).not_to be_valid
    end

    it "should be invalid when :description is not supplied" do
      expect(Marketplace::Product.new(@params.merge(description: nil))).not_to be_valid
    end

    it "should be invalid when :unit_size is not supplied" do
      expect(Marketplace::Product.new(@params.merge(unit_size: nil))).not_to be_valid
    end

    describe "unit_size length" do
      it "should be invalid when :unit_size is blank" do
        expect(Marketplace::Product.new(@params.merge(unit_size: ""))).not_to be_valid
        expect(Marketplace::Product.new(@params.merge(unit_size: "a"))).to be_valid
      end

      it "should be invalid when :unit_size is greater than 255 characters" do
        expect(Marketplace::Product.new(@params.merge(unit_size: "a"*255))).to be_valid
        expect(Marketplace::Product.new(@params.merge(unit_size: "a"*256))).not_to be_valid
      end
    end

    describe "name length" do
      it "should be invalid when :name is less than 3 characters" do
        expect(Marketplace::Product.new(@params.merge(name: "a"*2))).not_to be_valid
        expect(Marketplace::Product.new(@params.merge(name: "a"*3))).to be_valid
      end

      it "should be invalid when :name is greater than 255 characters" do
        expect(Marketplace::Product.new(@params.merge(name: "a"*255))).to be_valid
        expect(Marketplace::Product.new(@params.merge(name: "a"*256))).not_to be_valid
      end
    end

    describe "description length" do
      it "should be invalid when :description is less than 3 characters" do
        expect(Marketplace::Product.new(@params.merge(description: "a"*2))).not_to be_valid
        expect(Marketplace::Product.new(@params.merge(description: "a"*3))).to be_valid
      end

      it "should be invalid when :description is greater than 255 characters" do
        expect(Marketplace::Product.new(@params.merge(description: "a"*1000))).to be_valid
        expect(Marketplace::Product.new(@params.merge(description: "a"*1001))).not_to be_valid
      end
    end

    describe "name uniqueness" do
      before :all do
        @product = @pharmacy.products.create(@params)
        @other_pharmacy = create_pharmacy(name: "Other pharmacy", email: "info@otherpharmacy.com")
      end

      describe "product active" do
        before :each do
          @new_params = @params.merge(active: true)
        end

        it "should be invalid if :name and :unit_size is not unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params)).to be_invalid
        end

        it "should be valid if :name is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(name: "New_name"))).to be_valid
        end

        it "should be valid if :unit_size is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(unit_size: "80 capsules"))).to be_valid
        end

        it "should be valid if :unit_size is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(unit_size: "80 capsules"))).to be_valid
        end

        it "should be valid if duplicate product belongs to a different pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(pharmacy: @other_pharmacy))).to be_valid
        end
      end

      describe "product inactive" do
        before :each do
          @new_params = @params.merge(active: false)
        end

        it "should be valid if :name and :unit_size are not unique for the pharmacy" do
          expect(@pharmacy.products.build(@new_params)).to be_valid
        end
      end
    end
  end
end
