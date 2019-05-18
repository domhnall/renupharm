class Marketplace::Sale < Marketplace::Order
  MIN_AGE_FOR_CLEARING_DAYS = 30.freeze

  has_one :seller_fee, through: :payment, source: :fees, class_name: "Marketplace::Accounts::SellerFee"

  scope :for_pharmacy, ->(pharmacy){
    joins(line_items: { listing: :pharmacy })
    .where("marketplace_pharmacies.id = ?", pharmacy.id)
    .not_in_progress
    .distinct
  }

  scope :paid_out, ->{ completed.where.not(marketplace_seller_payout_id: nil) }

  scope :not_paid_out, ->{ completed.where(marketplace_seller_payout_id: nil) }

  def self.cleared(date = Date.today)
    joins(:history_items)
    .where(marketplace_order_history_items: { to_state: Marketplace::Order::State::COMPLETED })
    .where("marketplace_order_history_items.created_at < ?", date - MIN_AGE_FOR_CLEARING_DAYS.days)
    .distinct
  end

  def seller_earning
    seller_fee&.price
  end

  def cleared?(date = Time.now)
    completed? && (completed_at < date-MIN_AGE_FOR_CLEARING_DAYS.days)
  end

  def uncleared?(date = Time.now)
    !cleared?(date)
  end

  def paid?
    cleared? && !!seller_payout
  end

  def completed_at
    return unless completed?
    history_items.where({
      from_state: Marketplace::Order::State::DELIVERY_IN_PROGRESS,
      to_state: Marketplace::Order::State::COMPLETED
    }).first&.created_at
  end
end
