class Marketplace::PurchasePolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope
      .joins(:pharmacy)
      .where("marketplace_pharmacies.id = ?", user.pharmacy.id)
      .not_in_progress
      .order(updated_at: :desc)
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || user.pharmacy==pharmacy
  end

  private

  def order
    record
  end

  def pharmacy
    order.pharmacy
  end
end
