class Marketplace::Accounts::Fee < ApplicationRecord
  belongs_to :payment,
    class_name: "Marketplace::Payment",
    foreign_key: :marketplace_payment_id,
    inverse_of: :fees

  validates :amount_cents, :currency_code, presence: true

  def calculate!
    raise NotImplementedError, "This should be implemented in a subclass"
  end
end
