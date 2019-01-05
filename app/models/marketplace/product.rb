class Marketplace::Product < ApplicationRecord
  include Marketplace::Sunspot::Product

  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :products,
    optional: true

  has_many :listings,
    class_name: "Marketplace::Listing",
    foreign_key: :marketplace_product_id,
    inverse_of: :product

  has_many_attached :images

  validates :name, :description, :unit_size, presence: true
  validates :name, length: { minimum: 3, maximum: 255 }
  validates :unit_size, length: { minimum: 1, maximum: 255 }
  validates :description, length: { minimum: 3, maximum: 1000 }
  validates :name, uniqueness: { scope: [:marketplace_pharmacy_id, :unit_size] }, if: :active?

  delegate :name,
           :description,
           :address, to: :pharmacy, prefix: true, allow_nil: true

  attr_accessor :delete_images

  after_save :clean_up_images!

  def image_urls
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, disposition: "attachment", only_path: true)
    end
  end

  private

  def clean_up_images!
    return if self.delete_images.blank?
    ids = self.delete_images.split(",").map(&:to_i)
    self.images.where(id: ids).each(&:purge_later)
  end
end
