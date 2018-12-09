module Marketplace::Sunspot::Listing
  extend ActiveSupport::Concern

  included do
    searchable if: :active, unless: :purchased_at do
      text :product_name, boost: 3.0
      text :product_description, boost: 2.0
      text :seller_name, :seller_description, :seller_address
      integer :marketplace_pharmacy_id
      integer :price_cents
      time :expiry
      time :created_at
      time :updated_at
    end
  end
end
