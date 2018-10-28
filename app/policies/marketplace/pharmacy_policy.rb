class Marketplace::PharmacyPolicy < AuthenticatedApplicationPolicy
  def show?
    true
  end

  def update?
    user.admin? || (user.pharmacy==record && record.active?)
  end

  def create?
    user.admin?
  end
end
