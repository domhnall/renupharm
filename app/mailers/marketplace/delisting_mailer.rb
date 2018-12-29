class Marketplace::DelistingMailer < ApplicationMailer
  def delisting_notification(listing_id:, agent_id:)
    return unless (@agent = Marketplace::Agent.where(id: agent_id).first)
    return unless (@listing = Marketplace::Listing.where(id: listing_id).first)
    mail(to: @agent.email, subject: I18n.t("mailers.marketplace.delisting_mailer.delisting_notification.subject"))
  end
end
