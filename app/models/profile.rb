class Profile < ApplicationRecord
  module Roles
    ADMIN = "admin"
    COURIER = "courier"
    PHARMACY = "pharmacy"

    def self.valid_roles
      [ADMIN, COURIER, PHARMACY]
    end
  end

  include ActsAsIrishPhoneContact
  belongs_to :user
  has_one_attached :avatar

  validates :first_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :surname, presence: true, length: {minimum: 2, maximum: 30}
  validates :role, presence: true, inclusion: {in: Profile::Roles::valid_roles}

  acts_as_irish_phone_contact :telephone

  def full_name
    [first_name, surname].join(" ")
  end

  Profile::Roles::valid_roles.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end
end
