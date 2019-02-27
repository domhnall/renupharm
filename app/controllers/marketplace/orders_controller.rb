class Marketplace::OrdersController < AuthenticatedController
  def show
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
  end

  def receipt
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
  end

  private

  def get_scope
    policy_scope(Marketplace::Order).not_in_progress
  end
end
