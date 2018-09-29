class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable,
         :validatable,
         :lockable,
         :trackable

  has_many :comments

  def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
  end

  def is_admin?
    email =~ /@renupharm.ie\Z/
  end
end
