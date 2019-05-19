class Marketplace::LineItem < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id

  belongs_to :listing,
    class_name: "Marketplace::Listing",
    foreign_key: :marketplace_listing_id

  validates :marketplace_listing_id, uniqueness: {
    scope: :marketplace_order_id,
    message: I18n.t("marketplace.cart.errors.duplicate_line_item") }

  delegate :product,
           :product_name,
           :selling_pharmacy,
           :pharmacy,
           :quantity,
           :price_cents,
           :expiry,
           :display_price, to: :listing

  scope :not_in_progress, ->{ joins(:order).merge(Marketplace::Order.not_in_progress) }

  before_destroy :ensure_not_completed!

  private

  def ensure_not_completed!
    throw(:abort) unless order.in_progress?
  end
end
