class Marketplace::BankAccountPolicy < AuthenticatedApplicationPolicy
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

  def bank_account
    record
  end

  def pharmacy
    bank_account.pharmacy
  end
end
