class SmsNotification < Notification
  def deliver
    gateway_respone = client.sms.send(
      from: "Renupharm",
      to: mobile_number,
      text: message
    )

    message_response = gateway_response.messages.first
    byebug
    if message_response.status == '0'
      puts "Sent message id=#{response.messages.first.message_id}"
      # Update SmsNotification model (self) with relevant details from response
    else
      puts "Error: #{message_response.error_text}"
    end
  end

  private

  def mobile_number
    #profile.telephone
    "447746926569"
  end

  def client
    @_client ||= Nexmo::Client.new({
      api_key: Rails.application.credentials.nexmo[:api_key],
      api_secret: Rails.application.credentials.nexmo[:api_secret]
    })
  end
end
