class Marketplace::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 255 }
  validates :email, email: true, presence: true, uniqueness: true
  validates :address_1, presence: true, length: { minimum: 3, maximum: 255 }
  validates :address_2, presence: true, length: { minimum: 3, maximum: 255 }
  validates :address_3, presence: true, length: { minimum: 3, maximum: 255 }
  validates :telephone, presence: true

  acts_as_irish_phone_contact :telephone
end
