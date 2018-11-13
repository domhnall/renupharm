class Marketplace::Payment < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_order_id,
    inverse_of: :payments,
    optional: true

  belongs_to :credit_card,
    class_name: "Marketplace::CreditCard",
    foreign_key: :marketplace_credit_card_id,
    inverse_of: :payments

  after_initialize :default_attributes
  before_save :set_renupharm_reference

  validates :amount_cents, :currency_code, presence: true

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
