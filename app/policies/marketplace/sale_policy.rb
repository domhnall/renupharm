class Marketplace::SalePolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope
      .joins(line_items: { listing: :pharmacy })
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
    order.selling_pharmacy
  end
end
