class Marketplace::OrderPolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope
      .joins(:pharmacy)
      .where("marketplace_pharmacies.id = ?", user.pharmacy.id)
    end
  end

  def index
    true
  end

  def show?
    user.admin? || user.pharmacy==pharmacy
  end

  def create?
    order.user==user
  end

  def update?
    order.user==user
  end

  private

  def order
    record
  end

  def pharmacy
    product.pharmacy
  end
end
