class Sales::Contact < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact
  belongs_to :sales_pharmacy, class_name: 'Sales::Pharmacy', optional: true
  has_many :survey_responses, foreign_key: :sales_contact_id, dependent: :nullify

  validates :first_name, :surname, presence: true
  validates :first_name, :surname, length: { maximum: 255 }
  validates :email, email: true, uniqueness: true, if: :email?
  validate :pharmacy_email_or_telephone_present?

  acts_as_irish_phone_contact :telephone

  def full_name
    [first_name, surname].select{|n| n.present? }.join(" ")
  end

  def pharmacy_name
    return unless sales_pharmacy
    sales_pharmacy.full_name
  end

  private

  def pharmacy_email_or_telephone_present?
    if sales_pharmacy_id.blank? && email.blank? && telephone.blank?
      errors.add(:base, I18n.t("sales.contact.errors.pharmacy_email_or_telephone_required"))
    end
  end
end
