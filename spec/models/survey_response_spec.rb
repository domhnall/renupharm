require 'rails_helper'

describe SurveyResponse do

  before :all do
    @params = {
      email: "joe@falloon.com",
      question_1: true,
      question_2: true,
      question_3: true,
      question_4: true,
      question_5: "200-500",
      additional_notes: "I would not buy short dated medications"
    }
  end

  it "should be valid" do
    expect(SurveyResponse.new(@params)).to be_valid
  end

  it "should set the field :full_response on saving" do
    survey_response = SurveyResponse.new(@params)
    expect(survey_response.full_response).to be_nil
    survey_response.save!
    expect(survey_response.reload.full_response).not_to be_nil
  end

  it "should set :full_response to a JSON representation of the full response" do
    survey_response = SurveyResponse.create!(@params)
    expect(survey_response.full_response).to eq @params.as_json
  end
end
