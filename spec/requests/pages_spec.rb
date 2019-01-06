require "rails_helper"

describe "public pages" do
  describe "unauthenticated user" do
    it "should be able to access the landing page" do
      get root_path
      expect(response.status).to eq 200
      ["REDUCE MEDICATION WASTAGE",
       "SOURCE LOW-COST MEDICATIONS",
       "SAVE TIME AND MONEY"].each do |carousel_text|
        expect(response.body).to include carousel_text
      end
    end

    it "should be able to access the privacy policy page" do
      get privacy_policy_pages_path
      expect(response.status).to eq 200
      expect(response.body).to include "PRIVACY POLICY"
    end

    it "should be able to access the cookie policy page" do
      get cookies_policy_pages_path
      expect(response.status).to eq 200
      expect(response.body).to include "COOKIE POLICY"
    end

    it "should be able to access the survey page" do
      get new_survey_response_path
      expect(response.status).to eq 200
      expect(response.body).to include I18n.t('surveys.heading')
    end

    it "should be able to access the terms and conditions page" do
      get terms_and_conditions_pages_path
      expect(response.status).to eq 200
      expect(response.body).to include "USER AGREEMENT"
    end
  end
end
