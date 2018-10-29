class Marketplace::ListingPolicy < AuthenticatedApplicationPolicy
  def show?
    user.admin? || (pharmacy.active? && listing.active?) || user.pharmacy==pharmacy
  end

  def create?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
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
