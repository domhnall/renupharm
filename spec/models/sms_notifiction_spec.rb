require 'rails_helper'

describe SmsNotification do
  include Factories::Base

  before :each do
    @user = create_user
    @params = {
      profile: @user.profile,
      message: "This is a test message",
      delivered: false,
      gateway_response: nil
    }

    @dummy_client = double("nexmo client")

    @success_params = {
      :"message-count" => "1",
      :"messages" => [{
        :"to" => "447746926569",
        :"message-id" => "1500000005B149C5",
        :"status" => "0",
        :"remaining-balance" => "5.96670000",
        :"message-price" => "0.03330000",
        :"network" => "23410"
      }]
    }

    @failure_params = {
      :"message-count" => "1",
      :"messages" => [{
        :"to" => "447746926569",
        :"message-id" => "1500000005B149C6",
        :"status" => "99",
      }]
    }

    allow(Nexmo::Client).to receive(:new).and_return(@dummy_client)
  end

  [:deliver, :valid_response?].each do |method|
    it "should respond to :#{method}" do
      expect(SmsNotification.new).to respond_to method
    end
  end

  describe "#valid_response?" do
    it "should return false where :gateway_response is not set" do
      expect(SmsNotification.new(@params.merge(gateway_response: nil)).valid_response?).to be_falsey
    end

    it "should return true where :gateway_response has a message status of zero" do
      expect(SmsNotification.new(@params.merge(gateway_response: @success_params)).valid_response?).to be_truthy
    end

    it "should return false where :gateway_response has a non-zero message status" do
      expect(SmsNotification.new(@params.merge(gateway_response: @failure_params)).valid_response?).to be_falsey
    end
  end

  describe "#deliver" do
    before :each do
      @sms_notification = SmsNotification.create!(@params)
    end

    describe "where response is successful" do
      before :each do
        allow(@dummy_client).to receive_message_chain(:sms, :send){ Nexmo::Entity.new(@success_params) }
      end

      it "should set the gateway_response on the SmsNotification model" do
        expect(@sms_notification.gateway_response).to be_nil
        @sms_notification.deliver
        expect(@sms_notification.gateway_response).to eq @success_params.deep_stringify_keys
      end

      it "should update the :delivered flag to true" do
        expect(@sms_notification.delivered).to be_falsey
        @sms_notification.deliver
        expect(@sms_notification.delivered).to be_truthy
      end

      it "should not send and error email to admin" do
        expect(Admin::ErrorMailer).not_to receive(:sms_error)
      end
    end

    describe "where response is unsuccessful" do
      before :each do
        allow(@dummy_client).to receive_message_chain(:sms, :send){ Nexmo::Entity.new(@failure_params) }
      end

      it "should set the gateway_response on the SmsNotification model" do
        expect(@sms_notification.gateway_response).to be_nil
        @sms_notification.deliver
        expect(@sms_notification.gateway_response).to eq @failure_params.deep_stringify_keys
      end

      it "should email admin about failure" do
        expect(Admin::ErrorMailer).to receive(:sms_error).with(sms_id: @sms_notification.id){ OpenStruct.new(deliver_later: true) }
        @sms_notification.deliver
      end
    end

    describe "where balance is below configured threshold" do
      before :each do
        @balance = 4.89
        @low_balance_params = @success_params.dup.tap do |res|
          res[:"messages"][0][:"remaining-balance"] = @balance.to_s
        end
        allow(@dummy_client).to receive_message_chain(:sms, :send){ Nexmo::Entity.new(@low_balance_params) }
      end

      it "should email admin to alert for low SMS balance" do
        expect(Admin::ErrorMailer).to receive(:sms_balance_alert).with(balance: @balance){ OpenStruct.new(deliver_later: true) }
        @sms_notification.deliver
      end
    end
  end
end
