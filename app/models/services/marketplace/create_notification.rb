class Services::Marketplace::CreateNotification
  attr_reader :recipient, :title, :message, :options, :admin_mailer_class

  def initialize(recipient: nil,
                 message: nil,
                 title: I18n.t("web_push_notification.title.default"),
                 options: {},
                 admin_mailer_class: Admin::ErrorMailer)
    raise ArgumentError, "The :recipient must have a mobile number" unless recipient && recipient.respond_to?(:telephone)
    raise ArgumentError, "A non-empty :message must be supplied " unless message.present?
    @recipient          = recipient
    @title              = title
    @message            = message
    @options            = options
    @admin_mailer_class = admin_mailer_class

    @errors = []
    @response = Services::Response.new(errors: @errors)
  end

  def call
    notification = WebPushNotification.create!(
      profile: recipient.profile,
      title: title,
      message: message,
      options: options
    )
    notification.push
    @response
  rescue Services::Error => e
    @errors << e
    @response
  rescue Exception => e
    admin_mailer_class.batch_error(message: e.message, backtrace: e.backtrace).deliver_later
    raise Services::Error, I18n.t("general.error")
  end
end
