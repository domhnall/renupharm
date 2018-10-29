class Marketplace::ProductPolicy < AuthenticatedApplicationPolicy
  class Scope
    def resolve
      scope
      .where(active: true)
      .where("marketplace_pharmacy_id IS NULL OR marketplace_pharmacy_id = ?", user.pharmacy.id)
    end
  end

  def show?
    (pharmacy.active? && product.active?) || user.admin? || user.pharmacy==pharmacy
  end

  def create?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  private

  def product
    record
  end

  def pharmacy
    product.pharmacy
  end
end
