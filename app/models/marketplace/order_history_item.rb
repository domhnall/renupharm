class Marketplace::OrderHistoryItem < ApplicationRecord
  belongs_to :order,
    class_name: "Markteplace::Order",
    foreign_key: :marketplace_order_id

  belongs_to :user,
    class_name: "User",
    foreign_key: :user_id
end
