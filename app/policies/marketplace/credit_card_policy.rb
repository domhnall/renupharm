class Marketplace::CreditCardPolicy < AuthenticatedApplicationPolicy
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
    user.admin? || (user.superintendent? && user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
    create?
  end

  private

  def credit_card
    record
  end

  def pharmacy
    credit_card.pharmacy
  end
end
