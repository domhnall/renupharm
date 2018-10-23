class Marketplace::Listing < ApplicationRecord
  ACCEPTABLE_EXPIRY_DAYS = 7

  belongs_to :product,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_product_id

  validates :quantity, :price_cents, :expiry, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than: 7999 }
  validate :verify_expiry_acceptable, if: :active

  def acceptable_expiry?
    expiry && expiry > (Date.today + ACCEPTABLE_EXPIRY_DAYS.days)
  end

  private

  def verify_expiry_acceptable
    unless acceptable_expiry?
      errors.add(:expiry, I18n.t("marketplace.listing.errors.minimum_expiry", days: ACCEPTABLE_EXPIRY_DAYS))
    end
  end
end
