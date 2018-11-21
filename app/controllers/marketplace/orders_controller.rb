class Marketplace::OrdersController < AuthenticatedController
  def show
    @order = current_user.pharmacy.orders.not_in_progress.find(params.fetch(:id).to_i)
  end

  private

  def get_scope(query)
    return scope = policy_scope(Marketplace::Order) if query.size<3
    scope#.where("name LIKE ?", "%#{query}%")
  end
end
