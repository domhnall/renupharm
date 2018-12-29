class Marketplace::BankAccount < ApplicationRecord
  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :bank_account

  validates :bic, :iban, presence: true
  validates :iban, format: { with: /\A[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}\z/ }
  validate :bic_length

  def bic=(bic)
    super(bic && bic.gsub(/\W/,''))
  end

  def iban=(iban)
    super(iban && iban.gsub(/\W/,''))
  end

  private

  def bic_length
    return if bic && (bic.size==8 || bic.size==11)
    errors.add(:bic, I18n.t("marketplace.bank_account.errors.bic_length"))
  end
end
