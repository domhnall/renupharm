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
  has_one :notification_config, dependent: :destroy
  has_many :web_push_subscriptions, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :surname, presence: true, length: {minimum: 2, maximum: 30}
  validates :role, presence: true, inclusion: {in: Profile::Roles::valid_roles}
  validates :accepted_terms, acceptance: { message: I18n.t("profile.errors.must_accept_terms") }, on: :update

  acts_as_irish_phone_contact :telephone

  after_create :create_default_associations

  enum country: [:ie, :uk]

  def full_name
    [first_name, surname].join(" ")
  end

  def accepted_terms
    !!accepted_terms_at
  end

  def accepted_terms=(accept)
    return unless accept && accept.to_s=="true"
    self.accepted_terms_at = Time.now
  end

  Profile::Roles::valid_roles.each do |role|
    define_method "#{role}?" do
      self.role == role
    end
  end

  # Used to determine if IE or UK phone contact
  def country_code
    if self.uk?
      UK_COUNTRY_CODE
    else
      IE_COUNTRY_CODE
    end
  end

  private

  def create_default_associations
    self.create_notification_config!
  end
end
