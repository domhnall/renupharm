class Sales::Contact < ApplicationRecord
  include EmailValidatable
  belongs_to :sales_pharmacy, class_name: 'Sales::Pharmacy', optional: true
  has_many :survey_responses, foreign_key: :sales_contact_id

  validates :first_name, :surname, presence: true
  validates :first_name, :surname, length: { maximum: 255 }
  validates :email, email: true, if: :email?
  validate :pharmacy_email_or_telephone_present?

  private

  def pharmacy_email_or_telephone_present?
    if sales_pharmacy_id.blank? && email.blank? && telephone.blank?
      errors.add(:base, I18n.t("sales.contact.errors.pharmacy_email_or_telephone_required"))
      "Pharmacy, email or telephone must be supplied"
    end
  end
end
