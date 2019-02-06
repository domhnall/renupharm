class Users::Agent < User
  has_one :agent,
    class_name: "Marketplace::Agent",
    foreign_key: :user_id,
    dependent: :destroy,
    inverse_of: :user

  has_one :pharmacy, through: :agent
  has_one :current_order, through: :agent

  delegate :superintendent?, to: :agent

  delegate :purchase_emails,
           :purchase_texts,
           :purchase_site_notifications,
           :sale_emails,
           :sale_texts,
           :sale_site_notifications, to: :notification_config

  def create_order!
    return if current_order
    agent.orders.create!({
      state: Marketplace::Order::State::IN_PROGRESS
    })
  end
end
