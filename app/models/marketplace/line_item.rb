class Marketplace::LineItem < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id

  belongs_to :listing,
    class_name: "Marketplace::Listing",
    foreign_key: :marketplace_listing_id

  delegate :product,
           :pharmacy,
           :quantity,
           :price_cents,
           :display_price, to: :listing
end
