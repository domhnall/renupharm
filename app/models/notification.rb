class Notification < ApplicationRecord
  belongs_to :profile

  def user
    profile.user
  end
end
