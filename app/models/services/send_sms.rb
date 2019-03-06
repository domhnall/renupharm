class Services::SendSms
  attr_reader :recipient, :message, :admin_mailer_class

  def initialize(recipient: nil, message: nil, admin_mailer_class: Admin::ErrorMailer)
    raise ArgumentError, "The :recipient must have a telephone number" unless recipient && recipient.telephone
    raise ArgumentError, "A non-empty :message must be supplied " unless message.present?
    @recipient          = recipient
    @message            = message
    @admin_mailer_class = admin_mailer_class

    @errors = []
    @response = Services::Response.new(errors: @errors)
  end

  def call
    sms = SmsNotification.create!(profile: recipient.profile, message: message)
    SendSmsJob.perform_later(sms.id)
    @response
  rescue Services::Error => e
    @errors << e
    @response
  rescue Exception => e
    admin_mailer_class.batch_error(message: e.message, backtrace: e.backtrace).deliver_later
    raise e
  end
end
