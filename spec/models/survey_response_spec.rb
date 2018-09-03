require 'rails_helper'

describe SurveyResponse do

  before :all do
    @contact = Sales::Contact.create({
      first_name: "Billy",
      surname: "Bob",
      email: "billy@bob.com"
    })
    @params = {
      sales_contact_id: @contact.id,
      question_1: true,
      question_2: true,
      question_3: true,
      question_4: true,
      question_5: "200_500",
      additional_notes: "I would not buy short dated medications"
    }
  end

  describe "instantiation" do
    it "should be valid" do
      expect(SurveyResponse.new(@params)).to be_valid
    end

    [:question_1, :question_2, :question_3, :question_4, :question_5].each do |required|
      it "should be invalid if :#{required} is not supplied" do
        expect(SurveyResponse.new(@params.merge({"#{required}" => nil}))).not_to be_valid
      end
    end

    SurveyResponse::WASTAGE_BUCKETS.each do |allowed|
      it "should be valid if :question_5 is set to '#{allowed}'" do
        expect(SurveyResponse.new(@params.merge({question_5: allowed}))).to be_valid
      end
    end

    %w(gt_200 300_500 lt_1000).each do |invalid|
      it "should be invalid if :question_5 is set to '#{invalid}'" do
        expect(SurveyResponse.new(@params.merge({question_5: invalid}))).not_to be_valid
      end
    end
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
