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
end
