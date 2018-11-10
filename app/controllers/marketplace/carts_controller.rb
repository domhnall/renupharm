class Marketplace::CartsController < AuthenticatedController
  def show
    @order = current_order
  end

  def update
    @order = current_order
    if @order.update_attributes(marketplace_order_params)
      flash[:success] = I18n.t("general.flash.update_successful")
    else
      flash[:error] = I18n.t("general.flash.error")
    end
    render 'show'
  end

  private

  def marketplace_order_params
    params.require(:marketplace_order).permit(:state, line_items_attributes: [:id, :marketplace_listing_id, :_destroy])
  end
end
