require 'rails_helper'

describe Marketplace::PharmaciesController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Baggs Boutique", email: "info@baggs.com")
    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)
    @other_user = create_agent(
      pharmacy: create_pharmacy(name: "Stewart's", email: "stu@stewarts.com"),
      user: create_user(email: "dave@other.com")
    ).user.becomes(Users::Agent)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: {id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show, params: {id: @pharmacy.id}
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show, params: {id: @pharmacy.id}
        expect(response.body).to render_template "marketplace/shared/pharmacies/show"
      end
    end
  end
end
