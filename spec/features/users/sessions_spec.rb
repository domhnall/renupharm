require "rails_helper"

describe "login" do

  describe "non authenticated user" do
    it "should be able to login" do
      visit new_user_session_path
      expect(page).to have_content I18n.t("devise.sessions.log_in")
    end
  end
end
