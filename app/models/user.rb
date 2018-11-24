class User < ApplicationRecord
  include EmailValidatable

  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable,
         :validatable,
         :lockable,
         :trackable

  has_many :comments, dependent: :nullify
  has_one :profile, dependent: :destroy

  accepts_nested_attributes_for :profile

  delegate :full_name,
           :telephone,
           :role,
           :admin?,
           :pharmacy?,
           :courier?, to: :profile

  validates :email, email: true
  validates :profile, presence: true

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def to_type
    case self.role
    when Profile::Roles::PHARMACY
      self.becomes(Users::Agent)
    when Profile::Roles::COURIER
      self.becomes(Users::Courier)
    when Profile::Roles::ADMIN
      self.becomes(Users::Admin)
    end
  end
end
