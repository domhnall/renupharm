class WebPushSubscription < ApplicationRecord
  belongs_to :profile

  validates :subscription, presence: true
end
