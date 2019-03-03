class WebPushSubscriptionsController < AuthenticatedController
  def create
    @subscription = current_profile.web_push_subscriptions.build(web_push_subscription_params)
    if @subscription.valid? && @subscription.save
      head :ok
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def current_profile
    current_user.profile
  end

  def web_push_subscription_params
    params
    .require(:web_push_subscription)
    .permit(
      subscription: {}
    )
  end
end
