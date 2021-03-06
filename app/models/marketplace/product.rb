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

  validates :name, :form, presence: true
  validates :pack_size, :weight, :volume, :channel_size, numericality: true, allow_nil: true
  validates :strength, format: { with: /\A[\d\.]+(\/[\d\.]+)?\z/ }, length: { minimum: 1, maximum: 20 }, allow_blank: true
  validates :name, length: { minimum: 3, maximum: 255 }
  validates :active_ingredient, length: { minimum: 3, maximum: 255 }, allow_nil: true, allow_blank: true
  validates :name, uniqueness: { scope: [:marketplace_pharmacy_id, :pack_size, :strength] }, if: :active?
  validates :form, inclusion: { in: Marketplace::ProductForm::PERMITTED }
  validate :conditional_product_form_validations

  delegate :name,
           :description,
           :address, to: :pharmacy, prefix: true, allow_nil: true

  delegate :name, to: :product_form, prefix: true

  delegate *Marketplace::ProductForm::PROPERTIES.map{|p| ["#{p}_unit", "#{p}_required?", "#{p}_meaningful?"]}.flatten.map(&:to_sym),
    to: :product_form,
    allow_nil: true

  attr_accessor :delete_images

  after_save :clean_up_images!
  before_destroy :ensure_no_listings!

  def product_form
    Marketplace::ProductForm::for(form)
  end

  def image_urls
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, disposition: "attachment", only_path: true)
    end
  end

  Marketplace::ProductForm::PROPERTIES.each do |prop|
    define_method("display_#{prop}") do
      return "" if self.send(prop).blank?
      [self.send(prop), self.send("#{prop}_unit")].join(' ')
    end
  end

  def as_select_json(opts = {})
    self.as_json(opts.merge(methods: [
      :image_urls,
      :display_pack_size,
      :display_strength,
      :display_volume,
      :display_identifier,
      :display_channel_size,
      :display_weight,
      :product_form_name
    ]))
  end

  private

  def clean_up_images!
    return if self.delete_images.blank?
    ids = self.delete_images.split(",").map(&:to_i)
    self.images.where(id: ids).each(&:purge_later)
  end

  def conditional_product_form_validations
    Marketplace::ProductForm::PROPERTIES.each do |prop|
      if self.send("#{prop}_required?") && self.send(prop).blank?
        errors.add(prop, "The field '#{prop}' must be supplied when form is '#{product_form_name}'")
      end
    end
  end

  def ensure_no_listings!
    throw(:abort) if listings.any?
  end
end
