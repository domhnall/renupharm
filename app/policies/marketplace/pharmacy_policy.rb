class Marketplace::PharmacyPolicy < AuthenticatedApplicationPolicy
  def show?
    pharmacy.active? || user.pharmacy==pharmacy || user.admin?
  end

  def update?
    (user.pharmacy==pharmacy && pharmacy.active?) || user.admin?
  end

  def create?
    user.admin?
  end

  private

  def pharmacy
    record
  end
end
