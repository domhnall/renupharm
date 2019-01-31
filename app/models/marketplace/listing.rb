class Marketplace::Listing < ApplicationRecord
  include Marketplace::Sunspot::Listing

  ACCEPTABLE_EXPIRY_DAYS = 7

  belongs_to :product,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_product_id,
    inverse_of: :listings

  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :listings

  has_many :line_items,
    class_name: "Marketplace::LineItem",
    foreign_key: :marketplace_listing_id,
    inverse_of: :listing,
    dependent: :destroy

  alias_method :selling_pharmacy, :pharmacy

  validates :quantity, :price_cents, :expiry, :batch_number, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than: 800, less_than: 50000 }
  validates :seller_note, length: { minimum: 3, maximum: 1000 }, allow_nil: true
  validates :batch_number, length: { minimum: 3, maximum: 32 }
  validate :verify_expiry_acceptable, if: :active

  delegate :name,
           :images, to: :product, prefix: true

  delegate :active_ingredient,
           :product_form_name,
           :manufacturer,
           :display_strength,
           :display_pack_size,
           :display_volume,
           :display_identifier,
           :display_channel_size, to: :product

  delegate :id,
           :name,
           :description,
           :address,
           :telephone,
           :email,
           :image, to: :pharmacy, prefix: :seller

  delegate :price_major,
           :price_minor,
           :currency_symbol,
           :display_price, to: :price

  scope :active_listings, ->{ where(active: true).where(purchased_at: nil) }

  after_initialize :default_pharmacy_id
  before_destroy :ensure_no_completed_line_items!, prepend: true

  def marketplace_pharmacy_id=(pharmacy_id)
    super(product&.marketplace_pharmacy_id || pharmacy_id)
  end

  def acceptable_expiry?
    expiry && expiry > (Date.today + ACCEPTABLE_EXPIRY_DAYS.days)
  end

  def price
    @price ||= Price.new(self.price_cents)
  end

  def display_name
    if active?
      "#{product_name}:: #{seller_name}"
    else
      "#{product_name}:: #{seller_name} (#{I18n.t("marketplace.listing.labels.inactive")})"
    end
  end

  def can_delete?
    line_items.not_in_progress.empty?
  end

  private

  def default_pharmacy_id
    return unless self.new_record?
    self.marketplace_pharmacy_id = product&.marketplace_pharmacy_id
  end

  def decimal_price
    sprintf("%0.2f", price_cents/100.to_f)
  end

  def verify_expiry_acceptable
    unless acceptable_expiry?
      errors.add(:expiry, I18n.t("marketplace.listing.errors.minimum_expiry", days: ACCEPTABLE_EXPIRY_DAYS))
    end
  end

  def ensure_no_completed_line_items!
    throw(:abort) unless can_delete?
  end
end
