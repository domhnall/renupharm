class Marketplace::Agent < ApplicationRecord
  belongs_to :user
  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id

  has_many :orders,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_agent_id

  has_one :current_order,
    ->{ where({ state: Marketplace::Order::State::IN_PROGRESS }) },
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_agent_id

  delegate :full_name,
           :telephone,
           :email, to: :user

  delegate :name, to: :pharmacy, prefix: true

  accepts_nested_attributes_for :user
end
