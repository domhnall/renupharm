class WebPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    WebPushNotification.find(notification_id).push
  end
end
