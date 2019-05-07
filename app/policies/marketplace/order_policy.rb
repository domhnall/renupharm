class Marketplace::OrderPolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      Marketplace::Order.where(id: sale_ids).or(Marketplace::Order.where(id: purchase_ids))
    end

    def sale_ids
      Marketplace::SalePolicy::Scope.new(user, Marketplace::Sale.all).resolve.pluck(:id)
    end

    def purchase_ids
      Marketplace::PurchasePolicy::Scope.new(user, Marketplace::Purchase.all).resolve.pluck(:id)
    end
  end

  def show?
    user.admin? || order.buying_pharmacy==user.pharmacy || order.selling_pharmacy==user.pharmacy
  end

  def create?
    order.user==user
  end

  def update?
    user.admin? ||
    (order.in_progress? && order.user.id==user.id) ||
    (order.placed? && order.selling_pharmacy==user.pharmacy) ||
    (order.delivering? && order.buying_pharmacy==user.pharmacy)
  end

  private

  def order
    record
  end
end
