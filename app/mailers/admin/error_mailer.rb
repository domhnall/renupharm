class Admin::ErrorMailer < ApplicationMailer
  DELIVER_TO = "dev@renupharm.ie"

  after_action :prevent_deliveries_in_development

  def batch_error(message:, backtrace:)
    @message   = message
    @backtrace = backtrace
    mail(to: DELIVER_TO, subject: "RenuPharm:: Batch Error")
  end

  def payment_error(order_id:, message:, backtrace:)
    @order     = Marketplace::Order.where(id: order_id).first
    @user      = @order.user
    @message   = message
    @backtrace = backtrace
    mail(to: DELIVER_TO, subject: "RenuPharm:: Payment Error")
  end

  private

  def prevent_deliveries_in_development
    mail.perform_deliveries = !Rails.env.development?
  end
end
