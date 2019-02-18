class Marketplace::CartsController < AuthenticatedController
  def show
    @order = current_order
  end

  def update
    @order = current_order
    @order.assign_attributes(marketplace_order_params)
    res = case @order.state
    when Marketplace::Order::State::PLACED
      ::Services::Marketplace::OrderCompleter.new({
        order: @order,
        token: get_token,
        email: get_email
      }).call
    else
      ::Services::Response.new
    end

    if res.success? && @order.valid?
      @order.save!
      flash[:success] = I18n.t("marketplace.cart.flash.update_successful")
    else
      res.errors.each{ |e| @order.errors.add(:base, e.message) }
    end
    render 'show'
  end

  private

  def marketplace_order_params
    params.require(:marketplace_order).permit(:state, line_items_attributes: [:id, :marketplace_listing_id, :_destroy])
  end

  def get_token
    params.fetch(:stripeToken)
  end

  def get_email
    params.fetch(:stripeEmail)
  end
end
