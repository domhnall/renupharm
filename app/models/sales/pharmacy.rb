class Sales::Pharmacy < ApplicationRecord
  validates :name, :address_1, :address_2, :telephone, presence: true
  validates :name, :address_1, :address_2, :address_3, :telephone, length: { maximum: 255 }
end
