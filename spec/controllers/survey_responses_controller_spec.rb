require 'rails_helper'

describe SurveyResponsesController do
  render_views
  describe "#new" do
    it "should return a successful response" do
      get :new
      expect(response.status).to eq 200
    end

    it "should render the survey template" do
      get :new
      expect(response.body).to include I18n.t("surveys.survey.intro")
    end

    it "should autopopulate the email field if supplied" do
      get :new, params: { email: "bobby@davro.com" }
      expect(response.body).to include "bobby@davro.com"
    end
  end

  describe "#create" do
    before :all do
      @survey_params = {
        question_1: true,
        question_2: false,
        question_3: true,
        question_4: true,
        question_5: "lt_200",
        additional_notes: "Some remark",
        sales_contact_attributes: {
          first_name: "John",
          surname: "Malahide",
          email: "john@malahide.ie",
          telephone: "(01)2345678"
        }
      }
    end

    it "should redirect to the root path" do
      post :create, params: { survey_response: @survey_params }
      expect(response.status).to eq 302
      expect(response).to redirect_to root_path
    end

    it "should add a flash message indicating success" do
      post :create, params: { survey_response: @survey_params }
      expect(flash[:notice]).to eq I18n.t("surveys.submissions.success")
    end

    it "should create a SurveyResponse record" do
      orig_count = SurveyResponse.count
      post :create, params: { survey_response: @survey_params }
      expect(SurveyResponse.count).to eq orig_count+1
    end

    it "should create a new Sales::Contact if one does not exist" do
      orig_count = Sales::Contact.count
      post :create, params: { survey_response: @survey_params }
      expect(Sales::Contact.count).to eq orig_count+1
    end

    describe "sales contact already exists" do
      before :all do
        @contact = Sales::Contact.create({
          first_name: "Harry",
          surname: "Stiles",
          email: "john@malahide.ie"
        })
      end

      it "should not create a new Sales::Contact record" do
        orig_count = Sales::Contact.count
        post :create, params: { survey_response: @survey_params }
        expect(Sales::Contact.count).to eq orig_count
      end

      it "should create a new SurveyResponse record" do
        total_survey_count = SurveyResponse.count
        post :create, params: { survey_response: @survey_params }
        expect(SurveyResponse.count).to eq total_survey_count+1
      end

      it "should associate the new response object with the existing contact" do
        orig_count = @contact.reload.survey_responses.count
        post :create, params: { survey_response: @survey_params }
        expect(@contact.reload.survey_responses.count).to eq orig_count+1
      end
    end
  end
end
