module Factories
  def create_user(attrs = {})
    User.new.tap do |user|
      user.email = attrs.fetch(:email, 'daffy@duck.com')
      user.password = 'foobar'
      user.password_confirmation = 'foobar'
      user.build_profile(attrs.fetch(:profile_attributes, {
        first_name: "Daffy",
        surname: "Duck",
        role: Profile::Roles::PHARMACY
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
end
