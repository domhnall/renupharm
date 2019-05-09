class Marketplace::OrderFeedbackPolicy < AuthenticatedApplicationPolicy
  def show?
    order_feedback.persisted? || (order.buying_pharmacy == user.pharmacy)
  end

  def create?
    order.completed? && (order.buying_pharmacy == user.pharmacy)
  end

  def update?
    create? && (order_feedback.user == user)
  end

  def destroy?
    update?
  end

  private

  def order_feedback
    record
  end

  def order
    order_feedback.order
  end
end
