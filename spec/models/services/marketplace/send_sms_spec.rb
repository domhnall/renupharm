require 'rails_helper'

describe Services::Marketplace::SendSms do
  include Factories::Base

  before :all do
    @user = create_user.tap do |user|
      user.profile.telephone = "0906420500"
    end

    @params = {
      recipient: @user,
      message: "You can pick your friends"
    }
  end

  [ :recipient,
    :message,
    :admin_mailer_class,
    :call ].each do |method|
    it "should respond to method :#{method}" do
      expect(Services::Marketplace::SendSms.new(@params)).to respond_to method
    end
  end

  describe "instantiation" do
    it "should raise an error if :recipient is not supplied" do
      expect{ Services::Marketplace::SendSms.new(@params.merge(recipient: nil)) }.to raise_error ArgumentError
    end

    it "should raise an error if :recipient does not have a telephone number" do
      expect{ Services::Marketplace::SendSms.new(@params.merge(recipient: create_user)) }.to raise_error ArgumentError
    end

    it "should raise an error if :message is not supplied" do
      expect{ Services::Marketplace::SendSms.new(@params.merge(message: nil)) }.to raise_error ArgumentError
    end

    it "should default the admin_mailer_class to Admin::ErrorMailer" do
      expect(Services::Marketplace::SendSms.new(@params).admin_mailer_class).to eq Admin::ErrorMailer
    end
  end

  describe "instance method" do
    describe "#call" do
      before :each do
        @dummy_client = double("dummy nexmo client")
        @service = Services::Marketplace::SendSms.new(@params)
        allow(Nexmo::Client).to receive(:new).and_return(@dummy_client)
        allow(@dummy_client).to receive_message_chain(:sms, :send){ Nexmo::Entity.new }
      end

      it "should do create a new SmsNotification record" do
        orig_count = SmsNotification.count
        @service.call
        expect(SmsNotification.count).to eq orig_count+1
      end

      describe "failures" do
        before :each do
          @dummy_notification = double('sms notification', id: 99, deliver: true)
          allow(SmsNotification).to receive(:create!).and_return(@dummy_notification)
          allow(SmsNotification).to receive(:find).and_return(@dummy_notification)
        end


        it "should invoke #deliver on the new SmsNotification model" do
          expect(@dummy_notification).to receive(:deliver)
          @service.call
        end

        it "should return a valid Services::Response object" do
          res = @service.call
          expect(res).to be_a Services::Response
          expect(res).to be_success
        end

        describe "where Service::Error is thrown" do
          before :each do
            allow(@dummy_notification).to receive(:deliver).and_raise(Services::Error, "service error")
          end

          it "should return a invalid Services::Response object" do
            res = @service.call
            expect(res).to be_a Services::Response
            expect(res).to be_failure
          end

          it "should not re-raise the error" do
            expect{ @service.call }.not_to raise_error
          end
        end

        describe "where another error is thrown" do
          before :each do
            allow(@dummy_notification).to receive(:deliver).and_raise(StandardError, "dummy error")
          end

          it "should send an error email" do
            expect(Admin::ErrorMailer).to receive(:batch_error).at_least(:once).and_call_original
            expect{ @service.call }.to raise_error StandardError
          end

          it "should raise the error" do
            expect{ @service.call }.to raise_error StandardError
          end
        end
      end
    end
  end
end
