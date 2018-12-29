class AuthenticatedApplicationPolicy < ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user && user.is_a?(User)
    super
  end
end
