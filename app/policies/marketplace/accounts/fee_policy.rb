class Marketplace::Accounts::FeePolicy < AuthenticatedApplicationPolicy
  def show?
    user.admin? || user.pharmacy==selling_pharmacy
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  private

  def fee
    record
  end

  def selling_pharmacy
    fee.selling_pharmacy
  end
end
