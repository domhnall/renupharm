module UsersHelper
  def devise_current_user
    @devise_current_user ||= warden.authenticate(:scope => :user)
  end

  def current_user
    return unless devise_current_user
    @_renupharm_user ||= case devise_current_user.role
    when Profile::Roles::PHARMACY
      devise_current_user.becomes(Users::Agent)
    when Profile::Roles::COURIER
      devise_current_user.becomes(Users::Courier)
    when Profile::Roles::ADMIN
      devise_current_user.becomes(Users::Admin)
    end
  end
end
