class SurveyResponsesController < ApplicationController
  def new
    @survey_response = SurveyResponse.new(sales_contact_attributes: { email: params.fetch(:email, "") })
  end

  def create
    byebug
    @survey_response = SurveyResponse.new(filtered_params)
    if @survey_response.save
      redirect_to root_path, notice: I18n.t('surveys.submission.success')
    else
      redirect_to new_survey_response_path, error: I18n.t('surveys.submission.error')
    end
  end

  private

  def filtered_params
    params.required(:survey_response).permit(*survey_response_params, sales_contact_attributes: sales_contact_params)
  end

  def survey_response_params
    [:question_1, :question_2, :question_3, :question_4, :question_5, :addition_notes]
  end

  def sales_contact_params
    [:id, :first_name, :surname, :email, :telephone]
  end
end
