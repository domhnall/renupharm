require 'rails_helper'

describe Sales::Contact do
  before :all do
    @pharmacy = Sales::Pharmacy.create({
      name: 'PurePharmacy',
      address_1: '99 Bun Road',
      address_2: 'Caketown',
      telephone: '(01)2345678'
    })
    @params = {
      sales_pharmacy_id: @pharmacy.id,
      first_name: 'Bobby',
      surname: 'Boucher',
      telephone: '(01)2345678',
      email: 'bobby@boucher.com'
    }
  end

  describe "initialization" do
    it "should be valid when all attributes are supplied" do
      expect(Sales::Contact.new(@params)).to be_valid
    end

    [:first_name, :surname].each do |required|
      it "should be invalid if :#{required} is nil" do
        expect(Sales::Contact.new(@params.merge("#{required}" => nil))).not_to be_valid
      end

      it "should be invalid if :#{required} is blank" do
        expect(Sales::Contact.new(@params.merge("#{required}" => ""))).not_to be_valid
      end
    end

    [:first_name, :surname].each do |attr|
      it "should be invalid if :#{attr} is more than 255 characters in length" do
        expect(Sales::Contact.new(@params.merge("#{attr}" => "x"*255))).to be_valid
        expect(Sales::Contact.new(@params.merge("#{attr}" => "x"*256))).not_to be_valid
      end
    end

    it "should be invalid if one of :sales_pharmacy_id, :email or :telephone is not supplied" do
      expect(Sales::Contact.new(@params.merge({
        sales_pharmacy_id: nil,
        email: nil,
        telephone: nil
      }))).not_to be_valid
    end

    it "should be valid if :email and :telephone are blank provided :sales_pharmacy_id is supplied" do
      expect(Sales::Contact.new(@params.merge({
        sales_pharmacy_id: @pharmacy.id,
        email: nil,
        telephone: nil
      }))).to be_valid
    end

    it "should be valid if :sales_pharmacy_id and :telephone are blank provided :email is supplied" do
      expect(Sales::Contact.new(@params.merge({
        sales_pharmacy_id: nil,
        email: 'bobby@boucher.com',
        telephone: nil
      }))).to be_valid
    end

    it "should be valid if :sales_pharmacy_id and :email are blank provided :telephone is supplied" do
      expect(Sales::Contact.new(@params.merge({
        sales_pharmacy_id: nil,
        email: nil,
        telephone: '(01)2345678',
      }))).to be_valid
    end

    #['john@.com', 'john.smith.com', 'david@localhost', 'rubbish'].each do |invalid_email|
    ['john@.com'].each do |invalid_email|
      it "should be invalid if :email is #{invalid_email} (invalid)", :focus do
        expect(Sales::Contact.new(@params.merge(email: invalid_email))).not_to be_valid
      end
    end
  end
end
