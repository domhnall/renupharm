module Marketplace::Sunspot::Product
  extend ActiveSupport::Concern

  included do
    searchable if: :active do
      text :name, boost: 3.0
      text :active_ingredient, boost: 2.0
      text :product_form_name
      text :strength
      text :manufacturer
      text :pharmacy_name
      text :pharmacy_description
      text :pharmacy_address
      integer :marketplace_pharmacy_id
      time :created_at
      time :updated_at
    end
  end
end
