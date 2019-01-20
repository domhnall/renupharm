module Marketplace::Sunspot::Listing
  extend ActiveSupport::Concern

  included do
    searchable if: :active, unless: :purchased_at do
      text :product_name, boost: 3.0
      text :active_ingredient, boost: 2.0
      text :product_form_name, boost: 2.0
      text :display_strength
      text :display_pack_size
      text :display_volume
      text :display_identifier
      text :display_channel_size
      text :manufacturer
      text :seller_note
      text :batch_number
      text :seller_name
      text :seller_description
      text :seller_address
      integer :marketplace_pharmacy_id
      integer :price_cents
      time :expiry
      time :created_at
      time :updated_at
    end
  end
end
