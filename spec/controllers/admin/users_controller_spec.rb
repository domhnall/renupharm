require 'rails_helper'

describe Admin::UsersController do
  include Factories::Base
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Jones' Pharmacy", email: "john@jones.com")
    @existing = create_user(email: "existing@user.com").tap do |user|
      create_agent(pharmacy: @pharmacy, user: user)
    end
    @user = create_user(email: "subject@user.com").tap do |user|
      create_agent(pharmacy: @pharmacy, user: user)
    end

    # This hack ensures the timestamp changes on User model on update, so
    # we can use the shared :update specs
    # Without this timestamp update the model looks unchanged as the JSON
    # representation is not updated until the email change is confirmed by
    # the user.
    sleep 1

    @create_params = {
      user: {
        email: "dodge@podge.com",
        password: "PeggyPeggy",
        password_confirmation: "PeggyPeggy",
        profile_attributes: {
          first_name: "Peggy",
          surname: "Olsen",
          role: Profile::Roles::PHARMACY
        }
      }
    }
    @update_params = @create_params.merge(id: @existing.id).tap do |update_params|
      update_params[:user][:email] = "stoge@podge.com"
      update_params[:user][:profile_attributes][:id] = @existing.profile.id
    end
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :update", User
  it_behaves_like "a basic admin controller with :destroy", User

  describe "an authenticated admin" do
    before :all do
      @admin = create_admin_user(email: "dom@renupharm.ie")
      @user = create_user(email: "gary@digney.com")
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display the email for each User" do
        get :index
        expect(response.body).to include @user.email
      end
    end

    describe "#update" do
      it "should be able to update the user password" do
        @update_params[:user].merge!(password: "Password1", password_confirmation: "Password1")
        orig_password = @existing.reload.encrypted_password
        put :update, params: @update_params
        expect(@existing.reload.encrypted_password).not_to eq orig_password
      end

      it "should be able to update profile without impacting password" do
        new_params = @update_params.dup.tap do |params|
          params[:user].merge!(password: "", password_confirmation: "")
          params[:user][:profile_attributes][:first_name] = "Geoffrey"
        end
        orig_password = @existing.reload.encrypted_password
        expect(@existing.reload.profile.first_name).not_to eq "Geoffrey"
        put :update, params: @update_params
        expect(@existing.reload.encrypted_password).to eq orig_password
        expect(@existing.reload.profile.first_name).to eq "Geoffrey"
      end
    end
  end
end
