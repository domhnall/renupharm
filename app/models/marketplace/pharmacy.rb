class Marketplace::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  has_many :agents,
    class_name: "Marketplace::Agent",
    foreign_key: :marketplace_pharmacy_id

  has_many :products,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_pharmacy_id

  has_one_attached :image

  validates :name, :address_1, :address_3, :telephone, presence: true
  validates :name, :address_1, :address_2, :address_3, length: { minimum: 3, maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :email, email: true
  validates :name, :email, uniqueness: true

  acts_as_irish_phone_contact [:telephone, :fax]
end
