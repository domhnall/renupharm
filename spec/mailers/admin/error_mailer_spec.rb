require 'rails_helper'

describe Admin::ErrorMailer do
  include Factories::Marketplace

  before :all do
    @error_message = "Too much jam"
    @backtrace     = ["Too much jam", "Jam on surface of roll",  "Seeping through sponge", "Jam centre at capacity"]
  end

  describe "#batch_error" do
    before :all do
      @mail = Admin::ErrorMailer.batch_error(message: @error_message, backtrace: @backtrace)
    end

    it 'should send a error notification email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq "RenuPharm:: Batch Error"
    end

    it 'should be sent to the dev email address' do
      expect(@mail.to).to include "dev@renupharm.ie"
    end

    describe 'mail content' do
      before :all do
        mail = Admin::ErrorMailer.batch_error(message: @error_message, backtrace: @backtrace)
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

          it 'should refer to the error message' do
            expect(@contents.body).to include @error_message
          end

          it 'should include the stack trace' do
            expect(@contents.body).to include @backtrace.first
          end
        end
      end
    end
  end

  describe "#payment_error" do
    before :all do
      @order = create_payment.order
      @mail = Admin::ErrorMailer.payment_error(order_id: @order.id, message: @error_message, backtrace: @backtrace)
    end

    it 'should send a error notification email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq "RenuPharm:: Payment Error"
    end

    it 'should be sent to the dev email address' do
      expect(@mail.to).to include "dev@renupharm.ie"
    end

    describe 'mail content' do
      before :all do
        mail = Admin::ErrorMailer.payment_error(order_id: @order.id, message: @error_message, backtrace: @backtrace)
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

          it 'should refer to the email of the impacted user' do
            expect(@contents.body).to include @order.user.email
          end

          it 'should include the order reference' do
            expect(@contents.body).to include @order.reference
          end

          it 'should refer to the error message' do
            expect(@contents.body).to include @error_message
          end

          it 'should include the stack trace' do
            expect(@contents.body).to include @backtrace.first
          end
        end
      end
    end
  end

  describe "#sms_error" do
    before :all do
      @sms = create_failing_sms
      @mail = Admin::ErrorMailer.sms_error(sms_id: @sms.id)
    end

    it 'should send a sms error email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq "RenuPharm:: SMS Error"
    end

    it 'should be sent to the dev email address' do
      expect(@mail.to).to include "dev@renupharm.ie"
    end

    describe 'mail content' do
      before :all do
        mail = Admin::ErrorMailer.sms_error(sms_id: @sms.id)
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

          it 'should refer to the ID of the impacted SmsNotification' do
            expect(@contents.body).to include @sms.id
          end

          it 'should include the actual SMS message text' do
            expect(@contents.body).to include @sms.message
          end

          it 'should include the gateway_response' do
            expect(@contents.body).to include @sms.gateway_response.dig("messages", 0, "message-id").to_s
          end
        end
      end
    end
  end

  describe "#sms_balance_alert" do
    before :all do
      @mail = Admin::ErrorMailer.sms_balance_alert(balance: "1.99")
    end

    it 'should send a low-balance email' do
      expect(@mail).not_to be_nil
      expect(@mail.subject).to eq "RenuPharm:: Low SMS balance"
    end

    it 'should be sent to the dev email address' do
      expect(@mail.to).to include "dev@renupharm.ie"
    end

    describe 'mail content' do
      before :all do
        mail = Admin::ErrorMailer.sms_balance_alert(balance: "1.99")
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

          it 'should include the actual balance reflected in the gateway response' do
            expect(@contents.body).to include "1.99"
          end
        end
      end
    end
  end
end
