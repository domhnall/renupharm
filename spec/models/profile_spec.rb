require 'rails_helper'

describe Profile do
  include Factories::Base

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

  [ :notification_config,
    :web_push_subscriptions ].each do |method|
    it "should respond to method :#{method}" do
      expect(Profile.new).to respond_to method
    end
  end

  # Country enum
  [ :ie?,
    :ie!,
    :uk?,
    :uk? ].each do |method|
    it "should respond to country enum method :#{method}" do
      expect(Profile.new).to respond_to method
    end
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

    it "should be invalid when :telephone exceeds length of 16 characters" do
      expect(Profile.new(@params.merge(telephone: "+353 11111111111"))).to be_valid
      expect(Profile.new(@params.merge(telephone: "+353 111111111111"))).not_to be_valid
    end

    it "should be invalid when :telephone has length of less than 11 characters" do
      expect(Profile.new(@params.merge(telephone: "+353 111111"))).to be_valid
      expect(Profile.new(@params.merge(telephone: "+353 11111"))).not_to be_valid
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

    describe "#accepted_terms" do
      it "should return true when :accepted_terms_at has been set" do
        expect(Profile.new(@params.merge(accepted_terms_at: Time.now)).accepted_terms).to be_truthy
      end

      it "should return false when :accepted_terms_at has not been set" do
        expect(Profile.new(@params.merge(accepted_terms_at: nil)).accepted_terms).to be_falsey
      end
    end

    describe "#country_code" do
      before :each do
        @profile = @user.profile
      end

      it "should return 'IE' when profile country is set to :ie" do
        @profile.ie!
        expect(@profile.country_code).to eq "IE"
      end

      it "should retrun 'UK' when profile country is set to :uk" do
        @profile.uk!
        expect(@profile.country_code).to eq "UK"
      end

      it "should return 'IE' when profile country is set to unknown value" do
        @profile.update_column(:country, 99)
        expect(@profile.country_code).to eq "IE"
      end
    end

    describe "#accepted_terms=" do
      before :each do
        @profile = Profile.new(@params)
      end

      it "should set :accepted_terms_at when passed a boolean value of true" do
        expect(@profile.accepted_terms_at).to be_nil
        @profile.accepted_terms = true
        expect(@profile.accepted_terms_at).not_to be_nil
      end

      it "should set :accepted_terms_at when passed a boolean value of true" do
        expect(@profile.accepted_terms_at).to be_nil
        @profile.accepted_terms = "true"
        expect(@profile.accepted_terms_at).not_to be_nil
      end

      it "should not set :accepted_terms_at when a nil value is passed" do
        expect(@profile.accepted_terms_at).to be_nil
        @profile.accepted_terms = nil
        expect(@profile.accepted_terms_at).to be_nil
      end

      it "should not set :accepted_terms_at when any other value is passed" do
        expect(@profile.accepted_terms_at).to be_nil
        @profile.accepted_terms = 32
        expect(@profile.accepted_terms_at).to be_nil
      end
    end

    describe "validating update of record" do
      before :all do
        @profile = Profile.create(@params)
      end

      it "should be invalid if :accepted_terms_at is not set" do
        expect(@profile).not_to be_valid
      end

      it "should be valid if :accepted_terms_at is set" do
        @profile.accepted_terms_at = Time.now
        expect(@profile).to be_valid
      end
    end
  end
end
