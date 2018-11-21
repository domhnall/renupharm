class Marketplace::OrderPolicy < AuthenticatedApplicationPolicy
  def show?
    order.user==user
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
end
