class Admin::ErrorMailer < ApplicationMailer
  DELIVER_TO = "dev@renupharm.ie"

  def payment_error(order_id:, error:)
    @order = Marketplace::Order.where(id: order_id).first
    @user  = @order.user
    @error = error
    mail(to: DELIVER_TO, subject: "RenuPharm:: Payment Error")
  end
end
