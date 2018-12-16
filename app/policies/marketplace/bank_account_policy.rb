class Marketplace::BankAccountPolicy < AuthenticatedApplicationPolicy
  def create?
    user.admin? || (user.pharmacy==pharmacy && pharmacy.active?)
  end

  def show?
    create?
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
