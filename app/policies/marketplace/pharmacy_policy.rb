class Marketplace::PharmacyPolicy < AuthenticatedApplicationPolicy
  def show?
    pharmacy.active? || user.admin? || user.pharmacy==pharmacy
  end

  def update?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def create?
    user.admin?
  end

  private

  def pharmacy
    record
  end
end
