class AuthenticatedController < ApplicationController
  layout 'dashboards'
  before_action :authenticate_user!
  before_action :create_order!
  before_action :redirect_to_accept_terms

  private

  def create_order!
    return unless current_user.pharmacy?
    current_user.create_order!
  end

  def redirect_to_accept_terms
    return if current_user.accepted_terms_at
    flash[:alert] = I18n.t("profile.errors.must_accept_terms")
    redirect_to accept_terms_and_conditions_profile_path
  end
end
