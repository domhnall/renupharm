require 'rails_helper'

describe WebPushNotification do
  include Factories::Base

  describe "instance method" do
    before :each do
      @profile = create_user.profile.tap do |profile|
        create_web_push_subscription(profile: profile)
        create_web_push_subscription(profile: profile)
      end

    end

    describe "#push" do
      it "should not invoke Webpush if profile has not subscriptions" do
        @profile_without_subscriptions = create_user.profile
        expect(Webpush).not_to receive(:payload_send)
        WebPushNotification.create(profile: @profile_without_subscriptions, message: "I will never be seen").push
      end

      it "should invoke Webpush for each subscription on the profile" do
        expect(Webpush).to receive(:payload_send).twice
        WebPushNotification.create(profile: @profile, message: "I will be sent twice").push
      end

      it "should remove a subscription if it throws an expired error" do
        error_raised = false
        allow(Webpush).to receive(:payload_send).exactly(2).times do
          if error_raised
            "SUCCESSFULLY NOTIFIED"
          else
            error_raised = true
            raise Webpush::ExpiredSubscription.new(OpenStruct.new(body: "User has cancelled this one!"), "www.renupharm.ie")
          end
        end
        expect(@profile.web_push_subscriptions.count).to eq 2
        WebPushNotification.create(profile: @profile, message: "I will be seen once").push
        expect(@profile.web_push_subscriptions.count).to eq 1
      end

      it "should email admin if any other errors are raised" do
        error_raised = false
        allow(Webpush).to receive(:payload_send).exactly(2).times do
          if error_raised
            "SUCCESSFULLY NOTIFIED"
          else
            error_raised = true
            raise StandardError, "Dummy error"
          end
        end
        expect(Admin::ErrorMailer).to receive(:web_push_error).once.and_return(OpenStruct.new(deliver_later: true))
        WebPushNotification.create(profile: @profile, message: "I will be seen once").push
      end
    end
  end
end
