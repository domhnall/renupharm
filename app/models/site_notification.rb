class SiteNotification < Notification
  include ActionView::Helpers::AssetUrlHelper

  def send
    profile.web_push_subscriptions.each{ |wps| send_for_subscription(wps) }
  end

  private

  def send_for_subscription(wps)
    return unless wps
    Webpush.payload_send( default_params.merge({
      message: payload,
      endpoint: wps.subscription["endpoint"],
      p256dh: wps.subscription["keys"]["p256dh"],
      auth: wps.subscription["keys"]["auth"],
    }))
  rescue Webpush::ExpiredSubscription => e
    wps.destroy
  rescue Exception => e
    Rails.logger.error(e)
    raise e
  end

  def payload
    JSON.generate({
      title: "Renupharm: Make sure your product is ready for collection to avoid charges!",
      body: message,
      icon: asset_path("logo_colour")
    })
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
