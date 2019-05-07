class Marketplace::OrdersController < AuthenticatedController
  def show
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
  end

  def receipt
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
  end

  def update
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :update?
    @order.state = @order.next_state
    if @order.save
      redirect_to marketplace_order_path(@order), flash: { success: I18n.t("general.flash.update_successful") }
    else
      render 'show', flash: { error: I18n.t("general.flash.error") }
    end
  end

  private

  def get_scope
    policy_scope(Marketplace::Order).not_in_progress
  end
end
