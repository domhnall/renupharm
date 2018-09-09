unless Rails.env.test?
 ActionMailer::Base.smtp_settings = Rails.application.credentials.sendgrid
end
