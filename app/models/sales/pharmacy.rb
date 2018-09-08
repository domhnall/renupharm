class Sales::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  validates :name, :address_1, :address_3, presence: true
  validates :name, :proprietor, :address_1, :address_2, :address_3, length: { maximum: 255 }
  #validates :name, uniqueness: { scope: :address_3, message: I18n.t("sales.pharmacy.errors.name_uniqueness") }
  validates :email, email: true, if: :email?
  validate :telephone_or_email_present

  acts_as_irish_phone_contact [:telephone_1, :telephone_2]

  private

  def telephone_or_email_present
    if email.blank? && telephone_1.blank?
      errors.add(:base, I18n.t("sales.pharmacy.errors.emaill_or_telephone_required"))
    end
  end
end
