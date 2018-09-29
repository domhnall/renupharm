class Sales::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, :address_1, :address_3, presence: true
  validates :name, :proprietor, :address_1, :address_2, :address_3, length: { maximum: 255 }
  validates :email, email: true, if: :email?
  validate :telephone_or_email_present

  acts_as_irish_phone_contact [:telephone, :fax]

  def address
    [address_1, address_2, address_3].compact.join(", ")
  end

  def full_name
    "#{name} (#{address_3})"
  end

  private

  def telephone_or_email_present
    if email.blank? && telephone.blank?
      errors.add(:base, I18n.t("sales.pharmacy.errors.emaill_or_telephone_required"))
    end
  end
end
