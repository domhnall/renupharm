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

  has_many :history_items,
    class_name: "Marketplace::OrderHistoryItem",
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
  scope :placed, ->{ where(state: Marketplace::Order::State::PLACED) }
  scope :completed, ->{ where(state: Marketplace::Order::State::COMPLETED) }
  scope :delivering, ->{ where(state: Marketplace::Order::State::DELIVERY_IN_PROGRESS) }

  delegate :price_cents,
           :price_major,
           :price_minor,
           :currency_symbol,
           :currency_code,
           :display_price, to: :price

  alias_method :buying_pharmacy, :pharmacy

  before_create :set_reference

  def price
    @price ||= Price.new(self.line_items.reduce(0){|sum,li| sum+=li.price_cents })
  end

  def product_names
    line_items.map(&:product_name).join(",")
  end

  def selling_pharmacy
    line_items.first&.selling_pharmacy
  end

  def bought_by?(pharmacy = nil)
    buying_pharmacy==pharmacy
  end

  def sold_by?(pharmacy = nil)
    selling_pharmacy==pharmacy
  end

  State::valid_states.each do |state|
    define_method("#{state}?") do
      self.state==state
    end
  end

  def next_state
    Marketplace::Order::State::valid_states[current_state_index+1]
  end

  def push_state!(user)
    self.state = next_state
    ActiveRecord::Base.transaction do
      self.save &&
      history_items.create({
        user: user,
        from_state: self.state_previous_change.first,
        to_state: self.state_previous_change.last
      })
    end
  end

  def delivery_due_at
    return unless placed_at
    WorkingDays.end_of_next_working_day_plus_one(placed_at)
  end

  private

  def set_reference
    self.reference ||= SecureRandom.uuid
  end

  def placed_at
    return if in_progress?
    history_items.where({
      from_state: Marketplace::Order::State::IN_PROGRESS,
      to_state: Marketplace::Order::State::PLACED
    }).first.created_at
  end

  def line_items_from_single_seller
    if self.line_items.map(&:selling_pharmacy).uniq.count > 1
      errors.add(:base, I18n.t("marketplace.order.errors.line_items_from_multiple_sellers"))
    end
  end

  def current_state_index
    Marketplace::Order::State::valid_states.index(self.state)
  end
end
