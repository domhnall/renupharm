class Sales::Pharmacy < ApplicationRecord
  include ActsAsIrishPhoneContact

  validates :name, :address_1, :address_2, :telephone_1, presence: true
  validates :name, :address_1, :address_2, :address_3, length: { maximum: 255 }

  acts_as_irish_phone_contact [:telephone_1, :telephone_2]
end
