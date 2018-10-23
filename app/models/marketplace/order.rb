class Marketplace::Order < ApplicationRecord
  MAX_LINE_ITEMS = 1
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

  has_many :line_items,
    class_name: "Marketplace::LineItem",
    foreign_key: :marketplace_order_id

  validates :state, presence: true, inclusion: {in: Marketplace::Order::State::valid_states}
  validate :max_line_items

  private

  def max_line_items
    if self.line_items.count > MAX_LINE_ITEMS
      errors.add(:base, I18n.t("marketplace.order.errors.max_line_items", max: MAX_LINE_ITEMS))
    end
  end
end
