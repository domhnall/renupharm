class Marketplace::Payment < ApplicationRecord
  belongs_to :order,
    class_name: "Marketplace::Order",
    foreign_key: :markeplace_order_id,
    inverse_of: :payments,
    optional: true

  belongs_to :credit_card,
    class_name: "Marketplace::CreditCard",
    foreign_key: :marketplace_credit_card_id,
    inverse_of: :payments

  before_save :set_renupharm_reference

  private

  def set_renupharm_reference
    self.renupharm_reference ||= SecureRandom.uuid
  end
end
