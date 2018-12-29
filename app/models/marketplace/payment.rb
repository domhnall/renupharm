class Marketplace::Payment < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id,
    inverse_of: :payment,
    optional: true

  belongs_to :credit_card,
    class_name: "Marketplace::CreditCard",
    foreign_key: :marketplace_credit_card_id,
    inverse_of: :payments

  has_many :fees,
    class_name: "Marketplace::Accounts::Fee",
    foreign_key: :marketplace_payment_id,
    dependent: :destroy,
    inverse_of: :payment

  after_initialize :default_attributes
  before_save :set_renupharm_reference

  validates :amount_cents, :currency_code, presence: true

  delegate :buying_pharmacy,
           :selling_pharmacy, to: :order, allow_nil: true

  def reference
    self.renupharm_reference
  end

  private

  def set_renupharm_reference
    self.renupharm_reference ||= SecureRandom.uuid
  end

  def default_attributes
    return unless self.new_record?
    self.amount_cents ||= order&.price_cents
    self.currency_code ||= "EUR"
  end
end
