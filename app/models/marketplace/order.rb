class Marketplace::Order < ApplicationRecord
  MAX_LINE_ITEMS = 1
  module State
    IN_PROGRESS = "in_progress"
    PLACED = "placed"
    DELIVERY_IN_PROGRESS = "delivering"
    COMPLETED = "completed"

    def self.valid_states
      [IN_PROGRESS, PLACED, DELIVERY_IN_PROGRESS, COMPLETED]
    end
  end

  belongs_to :agent,
    class_name: "Marketplace::Agent",
    foreign_key: :marketplace_agent_id,
    inverse_of: :orders

  has_many :line_items,
    class_name: "Marketplace::LineItem",
    foreign_key: :marketplace_order_id,
    inverse_of: :order

  has_one :payment,
    class_name: "Marketplace::Payment",
    foreign_key: :marketplace_order_id,
    inverse_of: :order

  has_one :user, through: :agent
  has_one :pharmacy, through: :agent

  validates :state, presence: true, inclusion: {in: Marketplace::Order::State::valid_states}
  validate :max_line_items

  accepts_nested_attributes_for :line_items, allow_destroy: true

  scope :not_in_progress, ->{ where(state: Marketplace::Order::State::valid_states - [Marketplace::Order::State::IN_PROGRESS]) }

  delegate :reference,
    to: :payment,
    allow_nil: true

  # TODO: Reuse logic across models with `acts_as_priceable :price_cents`
  def price_cents
    self.line_items.reduce(0){|sum,li| sum+=li.price_cents }
  end

  def display_price
    "#{Marketplace::Listing::currency_symbol}#{sprintf("%0.2f", price_cents/100.to_f)}"
  end

  def product
    line_items.first&.product
  end

  def seller
    line_items.first&.seller
  end

  State::valid_states.each do |state|
    define_method("#{state}?") do
      self.state==state
    end
  end

  private

  def max_line_items
    if self.line_items.count > MAX_LINE_ITEMS
      errors.add(:base, I18n.t("marketplace.order.errors.max_line_items", max: MAX_LINE_ITEMS))
    end
  end
end
