require 'rails_helper'

describe Marketplace::NotificationManager do
  include Factories::Marketplace

  before :all do
    @user = create_agent.user.tap do |user|
      user.profile.notification_config.update_attributes({
        purchase_emails: false,
        purchase_texts: false,
        purchase_site_notifications: false,
        sale_emails: false,
        sale_texts: false,
        sale_site_notifications: false
      })
    end.reload
    @event = Marketplace::NotificationManager::Event::PURCHASE
    @data = { order: create_payment.order }
  end

  describe "instantiation" do
    it "should raise an error when no argument supplied" do
      expect{ Marketplace::NotificationManager.new }.to raise_error ArgumentError
    end

    it "should raise an error unless the argument supplied is a valid User" do
      expect{ Marketplace::NotificationManager.new("user") }.to raise_error ArgumentError
    end

    it "should not raise any error if a valid User supplied" do
      expect(Marketplace::NotificationManager.new(@user)).not_to be_nil
    end

    it "should not raise any error if a valid Users::Agent supplied" do
      expect(Marketplace::NotificationManager.new(@user.becomes(Users::Agent))).not_to be_nil
    end

    it "should downcast the User model passed to be a Users::Agent" do
      expect(@user).not_to be_a Users::Agent
      expect(Marketplace::NotificationManager.new(@user).user).to be_a Users::Agent
    end
  end

  describe "class method" do
    describe "::notify" do
      it "should create a new instance of NotificationManager" do
        expect(Marketplace::NotificationManager).to receive(:new).with(@user).and_call_original
        Marketplace::NotificationManager::notify(@user, @event, @data)
      end

      it "should dispatch the #notify message to the NotificationManager instance with appropriate args" do
        dummy_manager = double("dummy manager")
        allow(Marketplace::NotificationManager).to receive(:new).with(@user).and_return(dummy_manager)
        expect(dummy_manager).to receive(:notify).with(@event, @data).once
        Marketplace::NotificationManager::notify(@user, @event, @data)
      end
    end
  end

  describe "instance method" do
    describe "#notify" do
      describe "where event is a PURCHASE" do
        before :each do
          @event = Marketplace::NotificationManager::Event::PURCHASE
        end

        describe "where user is configured to get SMS for purchases" do
          before :each do
            @user.profile.notification_config.update_column(:purchase_texts, true)
            @user.reload
          end

          it "should invoke the SendSms service" do
            expect(Services::Marketplace::SendSms).to receive(:new){ OpenStruct.new(call: true) }
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured NOT to get SMS for purchases" do
          before :each do
            @user.profile.notification_config.update_column(:purchase_texts, false)
            @user.reload
          end

          it "should NOT invoke the SendSms service" do
            expect(Services::Marketplace::SendSms).not_to receive(:new)
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured to get emails for purchases" do
          before :each do
            @user.profile.notification_config.update_column(:purchase_emails, true)
            @user.reload
          end

          it "should invoke the OrderMailer :purchase_notification" do
            expect(Marketplace::OrderMailer).to receive(:purchase_notification){ OpenStruct.new(deliver_later: true) }
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured NOT to get emails for purchases" do
          before :each do
            @user.profile.notification_config.update_column(:purchase_emails, false)
            @user.reload
          end

          it "should NOT invoke the OrderMailer :purchase_notification" do
            expect(Marketplace::OrderMailer).not_to receive(:purchase_notification)
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end
      end

      describe "where event is a SALE" do
        before :each do
          @event = Marketplace::NotificationManager::Event::SALE
        end

        describe "where user is configured to get SMS for sales" do
          before :each do
            @user.profile.notification_config.update_column(:sale_texts, true)
            @user.reload
          end

          it "should invoke the SendSms service" do
            expect(Services::Marketplace::SendSms).to receive(:new){ OpenStruct.new(call: true) }
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured NOT to get SMS for sales" do
          before :each do
            @user.profile.notification_config.update_column(:sale_texts, false)
            @user.reload
          end

          it "should NOT invoke the SendSms service" do
            expect(Services::Marketplace::SendSms).not_to receive(:new)
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured to get emails for sales" do
          before :each do
            @user.profile.notification_config.update_column(:sale_emails, true)
            @user.reload
          end

          it "should invoke the OrderMailer :sale_notification" do
            expect(Marketplace::OrderMailer).to receive(:sale_notification){ OpenStruct.new(deliver_later: true) }
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end

        describe "where user is configured NOT to get emails for sales" do
          before :each do
            @user.profile.notification_config.update_column(:sale_emails, false)
            @user.reload
          end

          it "should NOT invoke the OrderMailer :sale_notification" do
            expect(Marketplace::OrderMailer).not_to receive(:sale_notification)
            Marketplace::NotificationManager.new(@user).notify(@event, @data)
          end
        end
      end

      describe "where event is some unsupported event" do
        before :each do
          @event = "UNSUPPORTED_CRAP"
        end

        it "should raise a NotImplementedError" do
          expect{ Marketplace::NotificationManager.new(@user).notify(@event, @data) }.to raise_error NotImplementedError
        end
      end
    end
  end
end
