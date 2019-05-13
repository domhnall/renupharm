class Marketplace::Pharmacy < ApplicationRecord
  include EmailValidatable
  include ActsAsIrishPhoneContact

  has_many :agents,
    class_name: "Marketplace::Agent",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  has_many :products,
    class_name: "Marketplace::Product",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  has_many :listings,
    class_name: "Marketplace::Listing",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  has_many :orders, through: :agents

  has_many :credit_cards,
    class_name: "Marketplace::CreditCard",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  has_one :bank_account,
    class_name: "Marketplace::BankAccount",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  has_one_attached :image

  has_many :seller_payouts,
    class_name: "Marketplace::SellerPayout",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :pharmacy

  validates :name, :address_1, :address_3, :telephone, presence: true
  validates :name, :address_1, :address_3, length: { minimum: 3, maximum: 255 }
  validates :address_2, length: { minimum: 3, maximum: 255 }, if: :address_2
  validates :description, length: { maximum: 1000 }
  validates :email, email: true
  validates :name, :email, uniqueness: true

  acts_as_irish_phone_contact [:telephone, :fax]

  scope :active, ->{ where(active: true) }


  delegate :bank_name,
           :bic,
           :iban, to: :bank_account, allow_nil: true

  def address
    [address_1, address_2, address_3].reject{|a| a.blank? }.join(", ")
  end

  def default_card
    credit_cards.default.first || credit_cards.last
  end
end
