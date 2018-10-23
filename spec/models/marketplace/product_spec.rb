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
        unit_size: "40 capsules"
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
  end
end
