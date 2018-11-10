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

  has_one :user, through: :agent

  validates :state, presence: true, inclusion: {in: Marketplace::Order::State::valid_states}
  validate :max_line_items

  accepts_nested_attributes_for :line_items, allow_destroy: true

  # TODO: Reuse logic across models with `acts_as_priceable :price_cents`
  def price_cents
    self.line_items.reduce(0){|sum,li| sum+=li.price_cents }
  end

  def display_price
    "#{Marketplace::Listing::currency_symbol}#{sprintf("%0.2f", price_cents/100.to_f)}"
  end

  private

  def max_line_items
    if self.line_items.count > MAX_LINE_ITEMS
      errors.add(:base, I18n.t("marketplace.order.errors.max_line_items", max: MAX_LINE_ITEMS))
    end
  end
end
