require 'rails_helper'

describe Sales::Pharmacy do
  before :all do
    @params = {
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4",
      address_3: "Irishtown",
      telephone_1: "(01) 283 7188",
    }
  end

  describe "initialization" do
    it "should be valid when all attributes are defined" do
      expect(Sales::Pharmacy.new(@params)).to be_valid
    end

    it "should be valid when address_3 is not supplied" do
      expect(Sales::Pharmacy.new(@params.merge(address_3: nil))).to be_valid
      expect(Sales::Pharmacy.new(@params.merge(address_3: ""))).to be_valid
    end

    [:name, :address_1, :address_2, :telephone_1].each do |required|
      it "should be invalid when :#{required} is nil" do
        expect(Sales::Pharmacy.new(@params.merge("#{required}" => nil))).not_to be_valid
      end

      it "should be invalid when :#{required} is blank" do
        expect(Sales::Pharmacy.new(@params.merge("#{required}" => ""))).not_to be_valid
      end
    end

    [:name, :address_1, :address_2, :address_3].each do |attr|
      it "should be invalid when :#{attr} exceeds length of 255 characters" do
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "a"*255))).to be_valid
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "a"*256))).not_to be_valid
      end
    end

    [:telephone_1, :telephone_2].each do |attr|
      it "should be invalid when :#{attr} exceeds length of 11 characters" do
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "0"*11))).to be_valid
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "0"*12))).not_to be_valid
      end

      it "should be invalid when :#{attr} has length of less than 7 characters" do
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "0"*7))).to be_valid
        expect(Sales::Pharmacy.new(@params.merge("#{attr}" => "0"*6))).not_to be_valid
      end
    end

    [:telephone_1, :telephone_2].each do |attr|
      describe "setting :#{attr}" do
        { "41-123-4567" => "0411234567",
          "(41) 123 4567" => "0411234567",
          "(01) 283 7188" => "012837188",
          "1 283 7188" => "012837188" }.each do |supplied, cleaned|

            it "should store the value '#{cleaned}' when supplied the value '#{supplied}'" do
              expect(Sales::Pharmacy.new(@params.merge("#{attr}" => supplied)).send(attr)).to eq cleaned
            end
        end
      end
    end
  end
end
