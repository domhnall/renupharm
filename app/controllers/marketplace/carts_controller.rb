class Marketplace::CartsController < AuthenticatedController
  before_action :set_credit_cards, only: [:show, :update]

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
        customer_reference: get_customer_reference,
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
    params.fetch(:stripeToken, nil)
  end

  def get_customer_reference
    params.fetch(:stripeCustomer, nil)
  end

  def get_email
    params.fetch(:stripeEmail, nil)
  end

  def set_credit_cards
    @credit_cards = current_user.pharmacy.credit_cards.authorized
  end
end
