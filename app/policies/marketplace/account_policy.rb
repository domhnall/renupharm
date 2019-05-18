class Marketplace::AccountPolicy < AuthenticatedApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.where("marketplace_pharmacy_id = ?", user.pharmacy.id)
    end
  end

  def show?
    user.admin? || user.pharmacy==pharmacy
  end

  def create?
    false
  end

  def update?
    false
  end

  private

  def account
    record
  end

  def pharmacy
    account.pharmacy
  end
end
