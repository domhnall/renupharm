class SmsNotification < Notification
  MIN_BALANCE_THRESHOLD = 5.0

  attr_writer :client_class

  after_commit :alert_low_balance
  after_commit :alert_failing_delivery

  def user
    profile.user
  end

  def mobile_number
    profile.telephone.gsub(/\A\+/,"").gsub(/\s/,"")
  end

  def deliver
    self.gateway_response = client.sms.send(
      from: "Renupharm",
      to: mobile_number,
      text: message
    ).to_h
    self.delivered = valid_response?
    save!
  end

  def valid_response?
    message_response&.dig("status")=="0"
  end

  private

  def alert_low_balance
    return unless remaining_balance && remaining_balance<MIN_BALANCE_THRESHOLD
    Admin::ErrorMailer.sms_balance_alert(balance: remaining_balance).deliver_later
  end

  def alert_failing_delivery
    return unless message_response && !valid_response?
    Admin::ErrorMailer.sms_error(sms_id: id).deliver_later
  end

  def remaining_balance
    message_response&.dig("remaining-balance")&.to_f
  end

  def message_response
    gateway_response&.dig("messages", 0)
  end

  def client
    @_client ||= client_class.new({
      api_key: Rails.application.credentials.nexmo[:api_key],
      api_secret: Rails.application.credentials.nexmo[:api_secret]
    })
  end

  def client_class
    @client_class || (Rails.configuration.send_sms ? Nexmo::Client : DummyNexmoClient)
  end
end
