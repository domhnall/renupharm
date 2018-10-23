require 'rails_helper'

describe "dashboard page" do
  include Factories::Base

  before :all do
    @user = create_user
  end

  describe "unauthenticated user" do
    it "should redirect to the sign in page" do
      get dashboard_path
      expect(response.status).to eq 302
      expect(response).to redirect_to new_user_session_path
    end

    it "should set an appropriate flash message" do
      get dashboard_path
      expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
    end
  end

  describe "an authenticated user" do
    before :each do
      sign_in @user
    end

    it "should be able to access the dashboard page" do
      get dashboard_path
      expect(response.status).to eq 200
      ["Profile", "Account", "Logout"].each do |account_menu_item|
        expect(response.body).to include account_menu_item
      end
    end
  end
end
