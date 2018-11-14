class Marketplace::OrderMailer < ApplicationMailer
  def purchase_notification(agent_id: nil, order_id: nil)
    return unless (@agent = Marketplace::Agent.where(id: agent_id).first)
    return unless (@order = Marketplace::Order.where(id: order_id).first)
    @listing  = @order.line_items.first.listing
    @pharmacy = @order.pharmacy
    mail(to: @agent.email, subject: 'Your RenuPharm order has been placed')
  end

  def sale_notification(agent_id: nil, order_id: nil)
    return unless (@agent = Marketplace::Agent.where(id: agent_id).first)
    return unless (@order = Marketplace::Order.where(id: order_id).first)
    @listing  = @order.line_items.first.listing
    @pharmacy = listing.pharmacy
    mail(to: @agent.email, subject: 'Your RenuPharm Marketplace listing has been purchased!')
  end
end
