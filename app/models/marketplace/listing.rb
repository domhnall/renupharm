class Marketplace::Listing < ApplicationRecord
  ACCEPTABLE_EXPIRY_DAYS = 7
  CURRENCY_SYMBOLS = {
    gbp: "£",
    usd: "$",
    eur: "€"
  }

  belongs_to :product,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_product_id

  has_one :pharmacy, through: :product
  alias_method :seller, :pharmacy

  validates :quantity, :price_cents, :expiry, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than: 7999 }
  validate :verify_expiry_acceptable, if: :active

  delegate :name, :description, :unit_size, :images, to: :product, prefix: true
  delegate :name, :address, :telephone, :email, :image, to: :pharmacy, prefix: :seller

  def acceptable_expiry?
    expiry && expiry > (Date.today + ACCEPTABLE_EXPIRY_DAYS.days)
  end

  def currency_symbol
    CURRENCY_SYMBOLS[:eur]
  end

  def price_major
    decimal_price.split('.')[0]
  end

  def price_minor
    decimal_price.split('.')[1]
  end

  def display_price
    "#{currency_symbol}#{decimal_price}"
  end

  private

  def decimal_price
    sprintf("%0.2f", price_cents/100.to_f)
  end

  def verify_expiry_acceptable
    unless acceptable_expiry?
      errors.add(:expiry, I18n.t("marketplace.listing.errors.minimum_expiry", days: ACCEPTABLE_EXPIRY_DAYS))
    end
  end
end
