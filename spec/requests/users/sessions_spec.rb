require "rails_helper"

describe "user session pages" do
  include Factories::Base

  before :all do
    @user = create_user
  end

  describe "unauthenticated user" do
    it "should be able to access the login page" do
      get new_user_session_path
      expect(response.status).to eq 200
      expect(response.body).to include I18n.t("devise.sessions.log_in")
    end

    it "should be able to access the forgot password page" do
      get new_user_password_path
      expect(response.status).to eq 200
      expect(response.body).to include I18n.t("devise.passwords.forgot_your_password")
    end

    it "should be able to access the resend confirmation instructions page" do
      get new_user_confirmation_path
      expect(response.status).to eq 200
      expect(response.body).to include I18n.t("devise.confirmations.resend_instructions")
    end

    it "should be able to access the resend unlock instructions page" do
      get new_user_unlock_path
      expect(response.status).to eq 200
      expect(response.body).to include I18n.t("devise.unlocks.resend_instructions")
    end

    describe "accessing the account edit path" do
      it "should redirect the user to the sign in page" do
        get account_edit_path
        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        get account_edit_path
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "an authenticated user" do
      before :each do
        sign_in @user
      end

      it "should be able to access the account edit page" do
        get account_edit_path
        expect(response.status).to eq 200
        expect(response.body).to include I18n.t("devise.registrations.edit_account")
      end
    end
  end
end
