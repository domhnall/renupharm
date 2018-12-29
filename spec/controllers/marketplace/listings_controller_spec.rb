require 'rails_helper'

describe Marketplace::ListingsController do
  include Factories::Marketplace

  before :all do
    @user = create_agent(
      pharmacy: create_pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)
  end

  describe "#index" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :index
        expect(response.status).to eq 200
      end

      it "should render the :index template" do
        get :index
        expect(response.body).to render_template :index
      end
    end
  end
end
