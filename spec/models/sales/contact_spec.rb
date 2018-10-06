require 'rails_helper'

describe Sales::Contact do
  include Factories

  before :all do
    @pharmacy = Sales::Pharmacy.create!({
      name: 'PurePharmacy',
      address_1: '99 Bun Road',
      address_2: 'Caketown',
      address_3: 'Bunland',
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

    ['john@.com', 'john.smith.com', 'david@localhost', 'rubbish'].each do |invalid_email|
      it "should be invalid if :email is #{invalid_email} (invalid)" do
        expect(Sales::Contact.new(@params.merge(email: invalid_email))).not_to be_valid
      end
    end

    it "should be invalid when :telephone exceeds length of 11 characters" do
      expect(Sales::Contact.new(@params.merge(telephone: "0"*11))).to be_valid
      expect(Sales::Contact.new(@params.merge(telephone: "0"*12))).not_to be_valid
    end

    it "should be invalid when :#{attr} has length of less than 7 characters" do
      expect(Sales::Contact.new(@params.merge(telephone: "0"*7))).to be_valid
      expect(Sales::Contact.new(@params.merge(telephone: "0"*6))).not_to be_valid
    end

    it "should be invalid when a contact with the same email already exists" do
      expect(existing_contact = Sales::Contact.new(@params)).to be_valid
      existing_contact.save!
      expect(Sales::Contact.new(@params)).not_to be_valid
    end

    describe "setting :telephone" do
      { "41-123-4567" => "0411234567",
        "(41) 123 4567" => "0411234567",
        "(01) 283 7188" => "012837188",
        "1 283 7188" => "012837188" }.each do |supplied, cleaned|

          it "should store the value '#{cleaned}' when supplied the value '#{supplied}'" do
            expect(Sales::Contact.new(@params.merge(telephone: supplied)).telephone).to eq cleaned
          end
      end
    end
  end

  describe "instance method" do
    describe "#full_name" do
      it "should return the first_name and surname separated by a space" do
        expect(Sales::Contact.new(@params.merge(first_name: "John", surname: "Doe")).full_name).to eq "John Doe"
      end

      it "should just return the first_name if surname is null or blank" do
        expect(Sales::Contact.new(@params.merge(first_name: "John", surname: "")).full_name).to eq "John"
        expect(Sales::Contact.new(@params.merge(first_name: "John", surname: nil)).full_name).to eq "John"
      end

      it "should just return the surname if first name is null or blank" do
        expect(Sales::Contact.new(@params.merge(first_name: "", surname: "Doe")).full_name).to eq "Doe"
        expect(Sales::Contact.new(@params.merge(first_name: nil, surname: "Doe")).full_name).to eq "Doe"
      end
    end

    describe "#pharmacy_name" do
      it "should return the sales_pharmacy name" do
        expect(Sales::Contact.new(@params.merge(sales_pharmacy_id: @pharmacy.id)).pharmacy_name).to eq @pharmacy.full_name
      end

      it "should return nil if the sales_pharmacy is nil" do
        expect(Sales::Contact.new(@params.merge(sales_pharmacy_id: nil)).pharmacy_name).to be_nil
      end
    end

    describe "#email=" do
      it "should set the email field to the value passed" do
        expect(Sales::Contact.new(@params.merge(email: "joe@example.com")).email).to eq "joe@example.com"
      end

      it "should set the value to nil if the value passed is nil" do
        expect(Sales::Contact.new(@params.merge(email: nil)).email).to be_nil
      end

      it "should set the value to nil if the value passed is blank" do
        expect(Sales::Contact.new(@params.merge(email: "")).email).to be_nil
      end
    end
  end

  describe "destruction" do
    before :all do
      @admin = create_user(email: 'ron@renupharm.ie')
      @contact = Sales::Contact.new(@params).tap do |contact|
        contact.comments << Comment.new(user: @admin, body: "This guy is very approachable, but a bit mental.")
        contact.save!
      end
      @survey_response = SurveyResponse.create!({
        sales_contact_id: @contact.id,
        question_1: true,
        question_2: false,
        question_3: true,
        question_4: false,
        question_5: 'lt_200'
      })
    end

    it "should nullify FK on any related survey responses" do
      expect(@survey_response.reload.sales_contact_id).to eq @contact.id
      @contact.destroy
      expect(@survey_response.reload.sales_contact_id).to be_nil
    end

    it "should destroy all associated comments" do
      orig_count = Comment.count
      @contact.comments.reload
      @contact.destroy
      expect(Comment.count).to eq orig_count-1
    end
  end
end
