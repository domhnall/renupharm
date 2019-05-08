class Marketplace::OrderHistoryItem < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id

  belongs_to :user,
    class_name: "User",
    foreign_key: :user_id

  validates :from_state,
    :to_state,
    presence: true,
    inclusion: {in: Marketplace::Order::State::valid_states}
end
