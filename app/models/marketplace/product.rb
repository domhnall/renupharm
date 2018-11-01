class Marketplace::Product < ApplicationRecord
  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    optional: true

  has_many :listings,
    class_name: "Marketplace::Listing",
    foreign_key: :marketplace_product_id

  has_many_attached :images

  validates :name, :description, :unit_size, presence: true
  validates :name, length: { minimum: 3, maximum: 255 }
  validates :unit_size, length: { minimum: 1, maximum: 255 }
  validates :description, length: { minimum: 3, maximum: 1000 }
  validates :name, uniqueness: { scope: [:marketplace_pharmacy_id, :unit_size] }, if: :active?
end
