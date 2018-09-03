class SurveyResponsesController < ApplicationController
  def new
    @survey_response = SurveyResponse.new({
      sales_contact_attributes: { email: params.fetch(:email, "") }
    })
  end

  def create
    contact = Sales::Contact.find_by_email(params[:survey_response][:sales_contact_attributes][:email])
    @survey_response = SurveyResponse.new(filtered_params(contact && contact.id))
    if @survey_response.save
      redirect_to root_path, notice: I18n.t('surveys.submissions.success')
    else
      redirect_to new_survey_response_path, error: I18n.t('surveys.submissions.error')
    end
  end

  private

  def filtered_params(sales_contact_id = nil)
    params[:survey_response].merge!(sales_contact_id: sales_contact_id, sales_contact_attributes: nil) if sales_contact_id
    params.required(:survey_response).permit(*survey_response_params, sales_contact_attributes: sales_contact_params)
  end

  def survey_response_params
    [:sales_contact_id, :question_1, :question_2, :question_3, :question_4, :question_5, :addition_notes]
  end

  def sales_contact_params
    [ :first_name, :surname, :email, :telephone]
  end

  def existing_contact(email)
    Sales::Contact.find_by_email(email)
  end
end
