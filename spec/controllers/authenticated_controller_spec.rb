require 'rails_helper'

describe AuthenticatedController, type: :controller do
  include Factories::Marketplace

  controller do
    def index
      render plain: "Hello World"
    end
  end

  before :all do
    @user = create_agent.user.becomes(Users::Agent)
  end

  describe "unauthenticated user" do
    it "should redirect user to the sign in path" do
      get :index
      expect(response).to redirect_to new_user_session_path
    end

    it "should set an appropriate flash message" do
      get :index
      expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
    end
  end

  describe "authenticated user" do
    before :each do
      sign_in @user
    end

    it "should return a successful response" do
      get :index
      expect(response).to have_http_status 200
    end

    it "should reflect the response body returned by the controller" do
      get :index
      expect(response.body).to eq "Hello World"
    end

    describe "who has not accepted terms" do
      before :all do
        @user.profile.update_column(:accepted_terms_at, nil)
      end

      before :each do
        sign_in @user
      end

      it "should redirect the user to accept terms" do
        get :index
        expect(response).to redirect_to accept_terms_and_conditions_profile_path
      end

      it "should set an appropriate flash message" do
        get :index
        expect(flash[:alert]).to eq I18n.t("profile.errors.must_accept_terms")
      end
    end
  end
end
