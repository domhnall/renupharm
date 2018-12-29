class Marketplace::OrdersController < AuthenticatedController
  def show
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
  end

  private

  def get_scope(query="")
    policy_scope(Marketplace::Order).not_in_progress
  end
end
