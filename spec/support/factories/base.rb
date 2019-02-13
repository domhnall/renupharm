module Factories
  module Base
    def create_user(attrs = {})
      User.new.tap do |user|
        user.email = attrs.fetch(:email, Faker::Internet.email)
        user.password = 'foobar'
        user.password_confirmation = 'foobar'
        user.build_profile(attrs.fetch(:profile_attributes, {
          first_name: Faker::Name.first_name,
          surname: Faker::Name.last_name,
          role: attrs.fetch(:role){ Profile::Roles::PHARMACY },
          accepted_terms_at: Time.now
        }))
        user.skip_confirmation!
        user.save!
        user.confirm
      end
    end

    def create_admin_user(attrs = {})
      create_user(attrs).tap do |user|
        user.profile.update_column(:role, Profile::Roles::ADMIN)
      end
    end

    def create_daniel
      create_user({
        email: "daniel@renupharm.ie",
        profile_attributes: {
          first_name: "Daniel",
          surname: "Larusso",
          role: Profile::Roles::PHARMACY,
          accepted_terms_at: Time.now }
      }).tap do |user|
        user.profile.avatar.attach(io: File.open("#{Rails.root}/spec/support/images/karate_kid_2.jpeg"), filename: "daniel.jpeg")
      end
    end

    def create_johnny
      johnny = create_user({
        email: "johnny@renupharm.ie",
        profile_attributes: {
          first_name: "Johnny",
          surname: "Lawrence",
          role: Profile::Roles::PHARMACY,
          accepted_terms_at: Time.now }
      }).tap do |user|
        user.profile.avatar.attach(io: File.open("#{Rails.root}/spec/support/images/karate_kid_johnny.jpeg"), filename: "johnny.jpeg")
      end
    end

    def create_sms_notification(attrs = {})
      SmsNotification.new.tap do |sms|
        sms.profile = attrs.fetch(:profile, create_user.profile)
        sms.message = attrs.fetch(:message, Faker::Lorem.sentence(8))
        sms.gateway_response = attrs.fetch(:gateway_response, nil)
        sms.delivered = attrs.fetch(:delivered, false)
        sms.save!
      end
    end

    def create_successful_sms(attrs = {})
      create_sms_notification(gateway_response: {
        :"message-count" => "1",
        :"messages" => [{
          :"to" => "447746926569",
          :"message-id" => "1500000005B149C5",
          :"status" => "0",
          :"remaining-balance" => "5.96670000",
          :"message-price" => "0.03330000",
          :"network" => "23410"
        }]
      })
    end

    def create_failing_sms(attrs = {})
      SmsNotification.skip_callback(:commit, :after, :alert_failing_delivery)
      create_sms_notification(gateway_response: {
        :"message-count" => "1",
        :"messages" => [{
          :"to" => "447746926569",
          :"message-id" => "1500000005B149C6",
          :"status" => "99",
        }]
      })
    ensure
      SmsNotification.set_callback(:commit, :after, :alert_failing_delivery)
    end
  end
end
