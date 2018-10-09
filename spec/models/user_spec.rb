require 'rails_helper'

describe User do
  before :all do
    @params = {
      email: "johnny@bravo.com",
      password: "foobar",
      password_confirmation: "foobar",
      profile_attributes: {
        first_name: "James",
        surname: "Magill",
        telephone: "(01) 283 7188",
        role: Profile::Roles::PHARMACY
      }
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(User.new(@params)).to be_valid
    end

    it "should be invalid when :email is not supplied" do
      expect(User.new(@params.merge(email: ""))).not_to be_valid
      expect(User.new(@params.merge(email: nil))).not_to be_valid
    end

    it "should not be valid when :password is not supplied" do
      expect(User.new(@params.merge(password: ""))).not_to be_valid
      expect(User.new(@params.merge(password: nil))).not_to be_valid
    end

    it "should not be valid when :password_confirmation does not match password" do
      expect(User.new(@params.merge(password: "foobar", password_confirmation: ""))).not_to be_valid
      expect(User.new(@params.merge(password: "foobar", password_confirmation: "hoobar"))).not_to be_valid
      expect(User.new(@params.merge(password: "foobar", password_confirmation: "fooBar"))).not_to be_valid
    end
  end

  describe "instance method" do
    describe "#admin?" do
      it "should return true if the user has an admin profile" do
        admin_params = @params.dup.tap do |attrs|
          attrs[:profile_attributes][:role] = Profile::Roles::ADMIN
        end
        expect(User.new(admin_params)).to be_admin
      end

      it "should return false if the user has no associated profile" do
        expect(User.new(@params.except(:profile_attributes))).not_to be_admin
      end

      it "should return false if the user has an non-admin profile" do
        pharmacy_params = @params.dup.tap do |attrs|
          attrs[:profile_attributes][:role] = Profile::Roles::PHARMACY
        end
        expect(User.new(pharmacy_params)).not_to be_admin
      end
    end
  end

  describe "association" do
    before :all do
      @commentable = Sales::Pharmacy.create!({
        name: 'PurePharmacy',
        address_1: '99 Bun Road',
        address_2: 'Caketown',
        address_3: 'Bunland',
        telephone: '(01)2345678'
      })
      @user = User.new(@params).tap do |user|
        user.comments << Comment.new(commentable: @commentable, body: "This is my test comment")
        user.save!
      end
    end

    [ :comments ].each do |association|
      it "should have an association named :#{association}" do
        expect(@user).to respond_to association
      end
    end

    describe "comments" do
      it "should nullify FK on associated comments" do
        orig_count = Comment.count
        expect(Comment.where(user_id: @user.id).count).not_to eq 0
        @user.destroy
        expect(Comment.count).to eq orig_count
        expect(Comment.where(user_id: @user.id).count).to eq 0
      end
    end
  end
end
