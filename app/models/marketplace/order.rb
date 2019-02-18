class Marketplace::Order < ApplicationRecord
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
  has_many :listings, through: :line_items
  has_many :fees, through: :payment
  has_many :comments, as: :commentable, dependent: :destroy

  validates :state, presence: true, inclusion: {in: Marketplace::Order::State::valid_states}
  validate :line_items_from_single_seller

  accepts_nested_attributes_for :line_items, allow_destroy: true

  scope :not_in_progress, ->{ where(state: Marketplace::Order::State::valid_states - [Marketplace::Order::State::IN_PROGRESS]) }

  delegate :reference,
    to: :payment,
    allow_nil: true

  delegate :price_cents,
           :price_major,
           :price_minor,
           :currency_symbol,
           :currency_code,
           :display_price, to: :price

  alias_method :buying_pharmacy, :pharmacy

  def price
    @price ||= Price.new(self.line_items.reduce(0){|sum,li| sum+=li.price_cents })
  end

  def product_names
    line_items.map(&:product_name).join(",")
  end

  def selling_pharmacy
    line_items.first&.selling_pharmacy
  end

  State::valid_states.each do |state|
    define_method("#{state}?") do
      self.state==state
    end
  end

  private

  def line_items_from_single_seller
    if self.line_items.map(&:selling_pharmacy).uniq.count > 1
      errors.add(:base, I18n.t("marketplace.order.errors.line_items_from_multiple_sellers"))
    end
  end
end
