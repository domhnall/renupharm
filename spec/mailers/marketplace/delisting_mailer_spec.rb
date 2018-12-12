require 'rails_helper'

describe Marketplace::DelistingMailer do
  include Factories::Marketplace

  before :all do
    @listing = create_listing
    @agent   = create_agent(pharmacy: @listing.pharmacy)
  end

  describe "#purchase_notification" do
    before :all do
      @mail = Marketplace::DelistingMailer.delisting_notification(agent_id: @agent.id, listing_id: @listing.id)
    end

    it 'should set an appropriate subject for a delisting notification email' do
      expect(@mail.subject).to eq I18n.t("mailers.marketplace.delisting_mailer.delisting_notification.subject")
    end

    it 'should be sent to the email address associated with the agent' do
      expect(@mail.to).to include @agent.email
    end

    it_should_behave_like "a basic mailer with html and text", [
      "@listing.product_name",
      "@listing.display_price",
      "I18n.l(@listing.expiry, format: :short)"
    ]
  end
end
