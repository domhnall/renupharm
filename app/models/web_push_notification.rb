class WebPushNotification < Notification

  validates :title, presence: true, length: {minimum: 3, maximum: 50}

  def push
    profile.web_push_subscriptions.each{ |wps| push_for_subscription(wps) }
  end

  private

  def push_for_subscription(wps)
    return unless wps
    self.gateway_response = Webpush.payload_send( default_params.merge({
      message: payload,
      endpoint: wps.subscription["endpoint"],
      p256dh: wps.subscription["keys"]["p256dh"],
      auth: wps.subscription["keys"]["auth"],
    }))
    self.delivered = true
    self.save!
  rescue Webpush::ExpiredSubscription => e
    wps.destroy
  rescue Exception => e
    Admin::ErrorMailer.web_push_error(
      notification_id: self.id,
      message: e.message,
      backtrace: e.backtrace
    ).deliver_later
  end

  def payload
    JSON.generate({
      title: self.title,
      body: self.message,
      icon: ActionController::Base.helpers.image_path("logo_colour"),
      badge: ActionController::Base.helpers.image_path("favicon")
    }.merge(self.options || {}).compact)
  end

  def default_params
    {
      vapid: {
        subject: "mailto:dev@renupharm.ie",
        public_key: Rails.application.credentials.vapid[:public_key],
        private_key: Rails.application.credentials.vapid[:private_key]
      },
      ssl_timeout: 5, # value for Net::HTTP#ssl_timeout=, optional
      open_timeout: 5, # value for Net::HTTP#open_timeout=, optional
      read_timeout: 5 # value for Net::HTTP#read_timeout=, optional
    }
  end
end
