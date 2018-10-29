class User < ApplicationRecord
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
  has_one :agent, class_name: "Marketplace::Agent"
  has_one :pharmacy, through: :agent

  accepts_nested_attributes_for :profile

  delegate :full_name,
           :telephone,
           :admin?,
           :pharmacy?,
           :courier?, to: :profile

  validates :profile, presence: true

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
