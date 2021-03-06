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

  def sms_error(sms_id:)
    @sms = SmsNotification.where(id: sms_id).first
    mail(to: DELIVER_TO, subject: "RenuPharm:: SMS Error")
  end

  def sms_balance_alert(balance:)
    @balance = balance
    mail(to: DELIVER_TO, subject: "RenuPharm:: Low SMS balance")
  end

  def web_push_error(notification_id:, message:, backtrace:)
    @notification = WebPushNotification.where(id: notification_id).first
    @message      = message
    @backtrace    = backtrace
    mail(to: DELIVER_TO, subject: "RenuPharm:: Web Push Error")
  end

  private

  def prevent_deliveries_in_development
    mail.perform_deliveries = !Rails.env.development?
  end
end
