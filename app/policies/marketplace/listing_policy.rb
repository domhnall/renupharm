class Marketplace::ListingPolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.where("marketplace_pharmacy_id = ?", user.pharmacy.id)
    end
  end

  def show?
    (pharmacy.active? && listing.active?) || user.admin? || user.pharmacy==pharmacy
  end

  def create?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  private

  def listing
    record
  end

  def pharmacy
    listing.pharmacy
  end
end
