class Marketplace::ProductPolicy < AuthenticatedApplicationPolicy
  class Scope
    def resolve
      scope
      .where(active: true)
      .where("marketplace_pharmacy_id IS NULL OR marketplace_pharmacy_id = ?", user.pharmacy.id)
    end
  end

  def show?
    (pharmacy.active? && product.active?) || user.pharmacy==pharmacy || user.admin?
  end

  def create?
    (user.pharmacy==pharmacy && pharmacy.active?) || user.admin?
  end

  def update?
    (user.pharmacy==pharmacy && pharmacy.active?) || user.admin?
  end

  private

  def product
    record
  end

  def pharmacy
    product.pharmacy
  end
end
