module Marketplace::Sunspot::Product
  extend ActiveSupport::Concern

  included do
    searchable if: :active do
      text :name, boost: 3.0
      text :description, boost: 2.0
      text :pharmacy_name, :pharmacy_description, :pharmacy_address
      integer :marketplace_pharmacy_id
      time :created_at
      time :updated_at
    end
  end
end
