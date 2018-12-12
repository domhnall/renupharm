class Marketplace::OrderMailer < ApplicationMailer
  def purchase_notification(agent_id: nil, order_id: nil)
    return unless (@agent = Marketplace::Agent.where(id: agent_id).first)
    return unless (@order = Marketplace::Order.where(id: order_id).first)
    @listing  = @order.listings.first
    @pharmacy = @order.pharmacy
    mail(to: @agent.email, subject: I18n.t("mailers.marketplace.order_mailer.purchase_notification.subject"))
  end

  def sale_notification(agent_id: nil, order_id: nil)
    return unless (@agent = Marketplace::Agent.where(id: agent_id).first)
    return unless (@order = Marketplace::Order.where(id: order_id).first)
    @listing  = @order.listings.first
    @pharmacy = @listing.pharmacy
    mail(to: @agent.email, subject: I18n.t("mailers.marketplace.order_mailer.sale_notification.subject"))
  end
end
