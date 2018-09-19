module Factories
  def create_user(attrs = {})
    User.new.tap do |user|
      user.email = attrs.fetch(:email, 'daffy@duck.com')
      user.password = 'foobar'
      user.password_confirmation = 'foobar'
      user.skip_confirmation!
      user.save!
      user.confirm
    end
  end
end
