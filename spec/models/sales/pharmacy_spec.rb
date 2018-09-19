require 'rails_helper'

describe Sales::Pharmacy do
  before :all do
    @params = {
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone_1: "(01) 283 7188",
    }
  end

  describe "initialization" do
    it "should be valid when all attributes are defined" do
      expect(Sales::Pharmacy.new(@params)).to be_valid
    end

    it "should be valid when address_2 is not supplied" do
      expect(Sales::Pharmacy.new(@params.merge(address_2: nil))).to be_valid
      expect(Sales::Pharmacy.new(@params.merge(address_2: ""))).to be_valid
    end

    [:name, :address_1, :address_3].each do |required|
      it "should be invalid when :#{required} is nil" do
        expect(Sales::Pharmacy.new(@params.merge("#{required}" => nil))).not_to be_valid
      end

      it "should be invalid when :#{required} is blank" do
        expect(Sales::Pharmacy.new(@params.merge("#{required}" => ""))).not_to be_valid
      end
    end

    it "should be invalid when both :telephone_1 and :email are blank" do
      expect(Sales::Pharmacy.new(@params.merge(telephone_1: nil, email: nil))).not_to be_valid
    end

    it "should be valid when :telephone_1 is blank if :email is supplied" do
      expect(Sales::Pharmacy.new(@params.merge(telephone_1: nil, email: "dom@dom.com"))).to be_valid
    end

    it "should be valid when :email is blank if :telephone_1 is supplied" do
      expect(Sales::Pharmacy.new(@params.merge(telephone_1: "(01) 283 7188", email: nil))).to be_valid
    end

    [:name, :proprietor, :address_1, :address_2, :address_3].each do |attr|
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

    ['john@.com', 'john.smith.com', 'david@localhost', 'rubbish'].each do |invalid_email|
      it "should be invalid if :email is #{invalid_email} (invalid)" do
        expect(Sales::Pharmacy.new(@params.merge(email: invalid_email))).not_to be_valid
      end
    end
  end

  describe "instance method" do
    describe "#full_name" do
      it "should return the pharmacy name with area (address_3) in brackets" do
        expect(Sales::Pharmacy.new(@params.merge(name: "DrugsRUs", address_3: "Caketown")).full_name).to eq "DrugsRUs (Caketown)"
      end
    end
  end
end
