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

    it 'should send a sale notification email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq I18n.t("mailers.marketplace.order_mailer.purchase_notification.subject")
    end

    it 'should be sent to the email address associated with the agent' do
      expect(@mail.to).to include @buying_agent.email
    end

    describe 'mail content' do
      before :all do
        mail = Marketplace::OrderMailer.purchase_notification(agent_id: @buying_agent.id, order_id: @order.id)
        @html_contents = mail.body.parts.select{ |part| part.content_type =~ /text\/html/}.first
        @text_contents = mail.body.parts.select{ |part| part.content_type =~ /text\/plain/}.first
      end

      it 'should be composed of html and text parts' do
        expect(@html_contents).not_to be_nil
        expect(@text_contents).not_to be_nil
      end

      [ :text, :html ].each do |part|
        describe "#{part} part" do
          before :all do
            @contents = self.instance_variable_get("@#{part}_contents")
          end

          it 'should refer to the product name' do
            expect(@contents.body).to include @listing.product_name
          end

          it 'should include the transaction reference' do
            expect(@contents.body).to include @order.reference
          end
        end
      end
    end
  end

  describe "#sale_notification" do
    before :all do
      @mail = Marketplace::OrderMailer.sale_notification(agent_id: @selling_agent.id, order_id: @order.id)
    end

    it 'should send a sale notification email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq I18n.t("mailers.marketplace.order_mailer.sale_notification.subject")
    end

    it 'should be sent to the email address associated with the agent' do
      expect(@mail.to).to include @selling_agent.email
    end

    describe 'mail content' do
      before :all do
        mail = Marketplace::OrderMailer.sale_notification(agent_id: @selling_agent.id, order_id: @order.id)
        @html_contents = mail.body.parts.select{ |part| part.content_type =~ /text\/html/}.first
        @text_contents = mail.body.parts.select{ |part| part.content_type =~ /text\/plain/}.first
      end

      it 'should be composed of html and text parts' do
        expect(@html_contents).not_to be_nil
        expect(@text_contents).not_to be_nil
      end

      [ :text, :html ].each do |part|
        describe "#{part} part" do
          before :all do
            @contents = self.instance_variable_get("@#{part}_contents")
          end

          it 'should refer to the product name' do
            expect(@contents.body).to include @listing.product_name
          end

          it 'should include the transaction reference' do
            expect(@contents.body).to include @order.reference
          end
        end
      end
    end
  end
end
