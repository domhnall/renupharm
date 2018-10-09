require 'rails_helper'

describe Profile do
  include Factories

  before :all do
    @user = create_user(email: "pete@murphy.com")
    @params = {
      user_id: @user.id,
      first_name: "Peter",
      surname: "Murphy",
      telephone: "(01) 283 7188",
      role: Profile::Roles::valid_roles.sample
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Profile.new(@params)).to be_valid
    end

    it "should be invalid when :user_id is not supplied" do
      expect(Profile.new(@params.merge(user_id: nil))).not_to be_valid
    end

    it "should be invalid when :first_name is not supplied" do
      expect(Profile.new(@params.merge(first_name: nil))).not_to be_valid
      expect(Profile.new(@params.merge(first_name: ""))).not_to be_valid
    end

    it "should be invalid when :surname is not supplied" do
      expect(Profile.new(@params.merge(surname: nil))).not_to be_valid
      expect(Profile.new(@params.merge(surname: ""))).not_to be_valid
    end

    it "should be invalid when :first_name is less than 2 characters in length" do
      expect(Profile.new(@params.merge(first_name: "aa"))).to be_valid
      expect(Profile.new(@params.merge(first_name: "a"))).not_to be_valid
    end

    it "should be invalid when :surname is less than 2 characters in length" do
      expect(Profile.new(@params.merge(surname: "aa"))).to be_valid
      expect(Profile.new(@params.merge(surname: "a"))).not_to be_valid
    end

    it "should be invalid when :first_name is more than 30 characters in length" do
      expect(Profile.new(@params.merge(first_name: "a"*30))).to be_valid
      expect(Profile.new(@params.merge(first_name: "a"*31))).not_to be_valid
    end

    it "should be invalid when :surname is less than 2 characters in length" do
      expect(Profile.new(@params.merge(surname: "a"*30))).to be_valid
      expect(Profile.new(@params.merge(surname: "a"*31))).not_to be_valid
    end

    it "should be invalid when :telephone exceeds length of 11 characters" do
      expect(Profile.new(@params.merge(telephone: "0"*11))).to be_valid
      expect(Profile.new(@params.merge(telephone: "0"*12))).not_to be_valid
    end

    it "should be invalid when :telephone has length of less than 7 characters" do
      expect(Profile.new(@params.merge(telephone: "0"*7))).to be_valid
      expect(Profile.new(@params.merge(telephone: "0"*6))).not_to be_valid
    end

    it "should be invalid when :role is blank" do
      expect(Profile.new(@params.merge(role: nil))).not_to be_valid
      expect(Profile.new(@params.merge(role: ""))).not_to be_valid
    end

    it "should be invalid when :role is not one of admin, pharmacy or courier" do
      expect(Profile.new(@params.merge(role: 'administrator'))).not_to be_valid
      expect(Profile.new(@params.merge(role: 'shop'))).not_to be_valid
      expect(Profile.new(@params.merge(role: 'admin,pharmacy'))).not_to be_valid
    end
  end

  describe "instance method" do
    describe "#full_name" do
      it "should return the concatenation of first_name and surname" do
        expect(Profile.new(@params).full_name).to eq "Peter Murphy"
      end
    end

    describe "#admin?" do
      it "should return true if the profile has the admin role" do
        expect(Profile.new(@params.merge(role: "admin"))).to be_admin
      end

      it "should return false if the profile does not have the admin role" do
        expect(Profile.new(@params.merge(role: "courier"))).not_to be_admin
      end
    end

    describe "#courier?" do
      it "should return true if the profile has the courier role" do
        expect(Profile.new(@params.merge(role: "courier"))).to be_courier
      end

      it "should return false if the profile does not have the courier role" do
        expect(Profile.new(@params.merge(role: "pharmacy"))).not_to be_courier
      end
    end

    describe "#pharmacy?" do
      it "should return true if the profile has the pharmacy role" do
        expect(Profile.new(@params.merge(role: "pharmacy"))).to be_pharmacy
      end

      it "should return false if the profile does not have the pharmacy role" do
        expect(Profile.new(@params.merge(role: "admin"))).not_to be_pharmacy
      end
    end
  end
end
