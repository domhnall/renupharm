class Marketplace::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  has_many :agents,
    class_name: "Marketplace::Agent",
    foreign_key: :marketplace_pharmacy_id

  has_many :products,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_pharmacy_id

  has_many :listings, through: :products

  has_one_attached :image

  validates :name, :address_1, :address_3, :telephone, presence: true
  validates :name, :address_1, :address_3, length: { minimum: 3, maximum: 255 }
  validates :address_2, length: { minimum: 3, maximum: 255 }, if: :address_2
  validates :description, length: { maximum: 1000 }
  validates :email, email: true
  validates :name, :email, uniqueness: true

  acts_as_irish_phone_contact [:telephone, :fax]

  scope :active, ->{ where(active: true) }

  def address
    [address_1, address_2, address_3].reject{|a| a.blank? }.join(", ")
  end
end
