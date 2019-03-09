require 'rails_helper'

describe ActsAsIrishPhoneContact do
  include Factories::Base

  before :each do
    @profile = create_user.profile
  end

  describe "validation" do
    it "should be invalid if root telephone number is less than 6 digits long" do
      @profile[:telephone] = "12345"
      expect(@profile).not_to be_valid
    end

    it "should be valid if root telephone number is 6 digits long" do
      @profile[:telephone] = "123456"
      expect(@profile).to be_valid
    end

    it "should be valid if root telephone number is up to 11 digits long" do
      @profile[:telephone] = "12345678910"
      expect(@profile).to be_valid
    end

    it "should be invalid if root telephone number is more than 11 digits long" do
      @profile[:telephone] = "123456789101"
      expect(@profile).not_to be_valid
    end
  end

  describe "instance method" do
    describe "#telephone" do
      it "should return a String" do
        expect(@profile.telephone).to be_a String
      end

      it "should prefix the phone number with '+353 '" do
        expect(@profile.telephone).to match /\A\+353 /
      end
    end

    describe "#telephone=" do
      it "should strip leading zeros from number supplied" do
        @profile.telephone = "012345678"
        expect(@profile[:telephone]).to eq "12345678"
      end

      it "should strip spaces from the number supplied" do
        @profile.telephone = "012 345 6789"
        expect(@profile[:telephone]).to eq "123456789"
      end

      it "should strip a leading 353 from the number supplied" do
        @profile.telephone = "35312 345 6789"
        expect(@profile[:telephone]).to eq "123456789"
      end

      it "should strip a leading +353 from the number supplied" do
        @profile.telephone = "+353 12 345 6789"
        expect(@profile[:telephone]).to eq "123456789"
      end

      it "should strip a leading 00353 from the number supplied" do
        @profile.telephone = "00353 12 345 6789"
        expect(@profile[:telephone]).to eq "123456789"
      end

      it "should strip area code 0 when supplied after 353" do
        @profile.telephone = "+353 (0)12 345 6789"
        expect(@profile[:telephone]).to eq "123456789"
      end

      [ "+353 123456", "+353 12345678", "+353 12345678901"].each do |number|
        it "should have no impact on a number such as #{number}" do
          @profile.telephone = number
          expect(@profile.telephone).to eq number
        end
      end
    end
  end
end
