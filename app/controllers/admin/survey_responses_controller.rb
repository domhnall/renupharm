class Admin::SurveyResponsesController < Admin::BaseController
  def index
    @survey_responses = SurveyResponse.all
  end
end
