require 'rails_helper'

describe Marketplace::PharmaciesController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Baggs Boutique", email: "info@baggs.com")
    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com"),
      superintendent: true
    ).user.becomes(Users::Agent)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: {pharmacy_id: @pharmacy.id, section: 'profile'}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show, params: {pharmacy_id: @pharmacy.id, section: 'profile'}
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show, params: {pharmacy_id: @pharmacy.id, section: 'profile'}
        expect(response.body).to render_template "marketplace/shared/pharmacies/show"
      end
    end
  end
end
