class Admin::BaseController < AuthenticatedController
  layout 'dashboards'
  before_action :ensure_is_admin

  private

  def ensure_is_admin
    raise Errors::AccessDenied unless current_user.admin?
  end
end
