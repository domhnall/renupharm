class SurveyResponsesController < ApplicationController
  def index
    @total_sales_pharmacies = Sales::Pharmacy.count
    @total_responses = SurveyResponse.count
    @stats = if @total_responses>0
      (0..3).map do |i|
        {yes: ((SurveyResponse.where("question_#{i+1} = 1").count/@total_responses.to_f)*100).round,
         no: ((SurveyResponse.where("question_#{i+1} = 0").count/@total_responses.to_f)*100).round }
      end
    else
      (0..3).map do |i|
        { yes: 0, no: 0 }
      end
    end

    labels = SurveyResponse::WASTAGE_BUCKETS.map{ |b| I18n.t("surveys.survey.question_5.labels.#{b}") }
    counts = SurveyResponse.group(:question_5).count
    @wastages_chart_presenter = Presenters::ChartPresenter.new(labels).tap do |presenter|
      presenter.add_dataset("Cost of medications disposed", SurveyResponse::WASTAGE_BUCKETS.map{ |b| (counts.fetch(b, 0)/@total_responses.to_f)*100 })
    end
    render layout: params.fetch(:layout, "true")=="false" ? false : true
  end

  def new
    @survey_response = SurveyResponse.new({
      sales_contact_attributes: { sales_pharmacy_id: get_pharmacy&.id,
                                  email: get_pharmacy && get_pharmacy.email }
    })
  end

  def create
    contact = Sales::Contact.find_by_email(params[:survey_response][:sales_contact_attributes][:email])
    @survey_response = SurveyResponse.new(filtered_params(contact && contact.id))
    verify_recaptcha(@survey_response)
    if @survey_response.valid? && @survey_response.save
      redirect_to root_path, flash: { success: I18n.t('surveys.submissions.success') }
    else
      flash.now[:warning] = I18n.t('surveys.submissions.error')
      render :new
    end
  end

  private

  def filtered_params(sales_contact_id = nil)
    params[:survey_response].merge!(sales_contact_id: sales_contact_id, sales_contact_attributes: nil) if sales_contact_id
    params.required(:survey_response).permit(*survey_response_params, sales_contact_attributes: sales_contact_params)
  end

  def survey_response_params
    [:sales_contact_id, :question_1, :question_2, :question_3, :question_4, :question_5, :additional_notes]
  end

  def sales_contact_params
    [ :sales_pharmacy_id, :first_name, :surname, :email, :telephone]
  end

  def existing_contact(email)
    @_sales_contact ||= Sales::Contact.find_by_email(email)
  end

  def verify_recaptcha(survey_response)
    unless verifier.verify(params["g-recaptcha-response"])
      survey_response.errors.add(:base, I18n.t("surveys.errors.recaptcha"))
    end
  end

  def verifier
    RecaptchaResponseVerifier.new(Rails.application.credentials.recaptcha)
  end

  def get_pharmacy
    @_sales_pharmacy ||= Sales::Pharmacy.find_by_id(params[:sales_pharmacy_id].to_i)
  end
end
