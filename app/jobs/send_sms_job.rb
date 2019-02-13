class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(sms_notification_id)
    SmsNotification.find(sms_notification_id).deliver
  end
end
