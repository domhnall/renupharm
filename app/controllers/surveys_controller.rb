class SurveysController < ApplicationController
  def new
  end

  def create
    redirect_to pages_path, notice: I18n.t('surveys.submission.success')
  end
end
