class Marketplace::ProductPolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.where("(marketplace_pharmacy_id IS NULL AND active = ?) OR marketplace_pharmacy_id = ?", true, user.pharmacy.id)
    end
  end

  def show?
    user.admin? ||
    user.pharmacy==pharmacy ||
    (product.active? && (pharmacy.nil? || pharmacy.active?))
  end

  def create?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def destroy?
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
