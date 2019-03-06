class Notification < ApplicationRecord
  belongs_to :profile

  validates :message, presence: true

  def user
    profile.user
  end
end
