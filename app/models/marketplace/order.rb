class Marketplace::Order < ApplicationRecord
  module State
    IN_PROGRESS = "in_progress"
    AWAITING_DELIVERY = "awaiting_delivery"
    DELIVERY_IN_PROGRESS = "delivering"
    COMPLETED = "completed"

    def self.valid_states
      [IN_PROGRESS, AWAITING_DELIVERY, DELIVERY_IN_PROGRESS, COMPLETED]
    end
  end

  belongs_to :agent,
    class_name: "Marketplace::Agent",
    foreign_key: :marketplace_agent_id

  validates :role, presence: true, inclusion: {in: Marketplace::Order::State::valid_states}
end
