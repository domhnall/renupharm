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
          role: Profile::Roles::PHARMACY }
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
          role: Profile::Roles::PHARMACY }
      }).tap do |user|
        user.profile.avatar.attach(io: File.open("#{Rails.root}/spec/support/images/karate_kid_johnny.jpeg"), filename: "johnny.jpeg")
      end
    end
  end
end
