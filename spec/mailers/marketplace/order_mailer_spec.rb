require 'rails_helper'

describe Marketplace::OrderMailer do
  include Factories::Marketplace

  before :all do
    create_payment.tap do |payment|
      @order         = payment.order
      @listing       = @order.listings.first
      @buying_agent  = payment.buying_pharmacy.agents.first
      @selling_agent = payment.selling_pharmacy.agents.first
    end
  end

  describe "#purchase_notification" do
    before :all do
      @mail = Marketplace::OrderMailer.purchase_notification(agent_id: @buying_agent.id, order_id: @order.id)
    end

    it 'should set an appropriate subject for a purchase notification email' do
      expect(@mail.subject).to eq I18n.t("mailers.marketplace.order_mailer.purchase_notification.subject")
    end

    it 'should be sent to the email address associated with the agent' do
      expect(@mail.to).to include @buying_agent.email
    end

    it_should_behave_like "a basic mailer with html and text", %w(@listing.product_name @order.reference)
  end

  describe "#sale_notification" do
    before :all do
      @mail = Marketplace::OrderMailer.sale_notification(agent_id: @selling_agent.id, order_id: @order.id)
    end

    it 'should set an appropriate subject for a sale notifcation email' do
      expect(@mail.subject).to eq I18n.t("mailers.marketplace.order_mailer.sale_notification.subject")
    end

    it 'should be sent to the email address associated with the agent' do
      expect(@mail.to).to include @selling_agent.email
    end

    it_should_behave_like "a basic mailer with html and text", %w(@listing.product_name @order.reference)
  end
end
