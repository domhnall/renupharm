class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable,
         :validatable,
         :lockable,
         :trackable

  def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
  end
end
