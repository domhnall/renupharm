class ApplicationController < ActionController::Base
  include UsersHelper
  include Pundit

  rescue_from Errors::AccessDenied, Pundit::NotAuthorizedError do |exception|
    flash[:error] ||= I18n.t('errors.access_denied')
    redirect_to(request.referrer || root_path)
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] ||= I18n.t('errors.record_not_found')
    redirect_to root_path, status: 404
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
