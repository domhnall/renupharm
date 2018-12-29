module UsersHelper
  def devise_current_user
    @devise_current_user ||= warden.authenticate(:scope => :user)
  end

  def current_user
    return unless devise_current_user
    @_renupharm_user ||= devise_current_user.to_type
  end

  def current_order
    current_user.pharmacy? && current_user.agent&.current_order
  end
end
