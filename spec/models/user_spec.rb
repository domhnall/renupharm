require 'rails_helper'

describe User do
  include Factories::Base

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

    it "should not be valid when :profile is not defined" do
      expect(User.new(@params.except(:profile_attributes))).not_to be_valid
    end

    ['john@.com', 'john.smith.com', 'david@localhost', 'rubbish'].each do |invalid_email|
      it "should be invalid if :email is #{invalid_email} (invalid)" do
        expect(User.new(@params.merge(email: invalid_email))).not_to be_valid
      end
    end
  end

  describe "instance method" do
    [:profile,
     :comments,
     :role,
     :admin?,
     :pharmacy?,
     :courier?,
     :full_name,
     :email,
     :telephone,
     :accepted_terms_at ].each do |method|
      it "should respond to :#{method}" do
        expect(User.new(@params)).to respond_to method
      end
    end

    describe "#admin?" do
      it "should return true if the user has an admin profile" do
        admin_params = @params.dup.tap do |attrs|
          attrs[:profile_attributes][:role] = Profile::Roles::ADMIN
        end
        expect(User.new(admin_params)).to be_admin
      end

      it "should return false if the user has an non-admin profile" do
        pharmacy_params = @params.dup.tap do |attrs|
          attrs[:profile_attributes][:role] = Profile::Roles::PHARMACY
        end
        expect(User.new(pharmacy_params)).not_to be_admin
      end
    end

    describe "#to_type" do
      before :all do
        @pharmacy_user = create_user({
          email: 'agent@pharmacy.com',
          role: Profile::Roles::PHARMACY
        })
        @admin_user = create_user({
          email: 'admin@renupharm.ie',
          role: Profile::Roles::ADMIN
        })
        @courier_user = create_user({
          email: 'courier@dpd.ie',
          role: Profile::Roles::COURIER
        })
      end

      it "should return an instance of Users::Agent where user is a pharmacy agent" do
        expect(@pharmacy_user.pharmacy?).to be_truthy
        expect(@pharmacy_user).not_to be_a Users::Agent
        expect(@pharmacy_user.to_type).to be_a Users::Agent
      end

      it "should return an instance of Users::Admin where devise_current_user is an admin" do
        expect(@admin_user.admin?).to be_truthy
        expect(@admin_user).not_to be_a Users::Admin
        expect(@admin_user.to_type).to be_a Users::Admin
      end

      it "should return an instance of Users::Courier where devise_current_user is a courier" do
        expect(@courier_user.courier?).to be_truthy
        expect(@courier_user).not_to be_a Users::Courier
        expect(@courier_user.to_type).to be_a Users::Courier
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

  describe "destruction" do
    before :each do
      @user = User.create!(@params.merge(email: "davy@destruction.com"))
    end

    it "should destroy the User model" do
      orig_count = User.count
      @user.destroy
      expect(User.count).to eq orig_count-1
    end

    it "should destroy the associated Profile model" do
      orig_count = Profile.count
      @user.destroy
      expect(Profile.count).to eq orig_count-1
    end
  end
end
