class Marketplace::OrderFeedbacksController < AuthenticatedController
  def create
    @order = get_order
    @feedback = @order.build_feedback(feedback_params.merge(user_id: current_user.id))
    if @feedback.save
      redirect_to marketplace_order_path(@order), flash: { success: I18n.t('marketplace.order_feedback.flash.create_successful') }
    else
      flash.now[:error] = I18n.t('marketplace.order_feedback.flash.error')
      render "marketplace/orders/show"
    end
  end

  def update
    @order = get_order
    @feedback = @order.feedback
    if @feedback.update_attributes(feedback_params)
      redirect_to marketplace_order_path(@order), flash: { success: I18n.t('marketplace.order_feedback.flash.update_successful') }
    else
      flash.now[:error] = I18n.t('marketplace.order_feedback.flash.error')
      render "marketplace/orders/show"
    end
  end

  private

  def pharmacy
    current_user.pharmacy
  end

  def get_order
    policy_scope(Marketplace::Order).find(params.fetch(:order_id).to_i)
  end

  def feedback_params
    params.require(:marketplace_order_feedback).permit(:rating, :message)
  end
end
