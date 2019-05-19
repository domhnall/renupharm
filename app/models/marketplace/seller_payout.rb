class Marketplace::SellerPayout < ApplicationRecord
  MIN_PAYOUT_CENTS = 2000

  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :seller_payouts

  belongs_to :user,
    class_name: "User",
    foreign_key: :user_id

  has_many :orders,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_seller_payout_id,
    inverse_of: :seller_payout,
    dependent: :nullify

  validates :total_cents, :currency_code, presence: true
  validates :total_cents, numericality: { only_integer: true, greater_than: MIN_PAYOUT_CENTS }
  validate :no_payout_for_incomplete_order

  before_validation :set_total_cents_and_currency_code

  def price
    Price.new(total_cents, currency_code)
  end

  private

  def set_total_cents_and_currency_code
    self.total_cents = orders.map{ |o| o.becomes(Marketplace::Sale) }.reduce(0) do |total, sale|
      total + (sale.seller_fee&.amount_cents || 0)
    end.round
    # TODO should really verify that all seller payouts are in the same currency here
    self.currency_code = "EUR"
  end

  def no_payout_for_incomplete_order
    unless self.orders.all?(&:completed?)
      errors.add(:orders, I18n.t("marketplace.order.errors.no_payout_for_incomplete_order"))
    end
  end
end
