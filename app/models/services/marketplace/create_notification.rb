class Services::Marketplace::CreateNotification
  attr_reader :recipient, :message, :admin_mailer_class

  def initialize(recipient: nil, message: nil, admin_mailer_class: Admin::ErrorMailer)
    raise ArgumentError, "The :recipient must have a mobile number" unless recipient && recipient.respond_to?(:telephone)
    raise ArgumentError, "A non-empty :message must be supplied " unless message.present?
    @recipient          = recipient
    @message            = message
    @admin_mailer_class = admin_mailer_class

    @errors = []
    @response = Services::Response.new(errors: @errors)
  end

  def call
    notification = SiteNotification.create!(profile: recipient.profile, message: message)
    # notification.send
    response
  rescue Services::Error => e
    @errors << e
    response
  rescue Exception => e
    admin_mailer_class.batch_error(message: e.message, backtrace: e.backtrace).deliver_later
    raise Services::Error, I18n.t("general.error")
  end
end
