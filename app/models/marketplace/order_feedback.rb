class Marketplace::OrderFeedback < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id

  belongs_to :user,
    class_name: "User",
    foreign_key: :user_id

  validates :message, length: { maximum: 1000 }
  validates :rating, presence: true, numericality: {
      only_integer: true,
      greater_than: 0,
      less_than_or_equal_to: 5
    }
end
