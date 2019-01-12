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

  validates :name, :active_ingredient, :form, presence: true
  validates :pack_size, :strength, numericality: true
  validates :name, :active_ingredient, length: { minimum: 3, maximum: 255 }
  validates :name, uniqueness: { scope: [:marketplace_pharmacy_id, :pack_size] }, if: :active?
  validates :form, inclusion: { in: Marketplace::ProductForm::PERMITTED }

  delegate :name,
           :description,
           :address, to: :pharmacy, prefix: true, allow_nil: true

  delegate :name, to: :product_form, prefix: true
  delegate :strength_unit,
           :pack_size_unit, to: :product_form, allow_nil: true

  attr_accessor :delete_images

  after_save :clean_up_images!

  def product_form
    Marketplace::ProductForm::for(form)
  end

  def image_urls
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, disposition: "attachment", only_path: true)
    end
  end

  def display_strength
    return "" if strength.blank?
    [strength, strength_unit].join(' ')
  end

  def display_pack_size
    return "" if pack_size.blank?
    [pack_size, pack_size_unit].join(' ')
  end

  private

  def clean_up_images!
    return if self.delete_images.blank?
    ids = self.delete_images.split(",").map(&:to_i)
    self.images.where(id: ids).each(&:purge_later)
  end
end
