class Users::Agent < User
  has_one :agent,
    class_name: "Marketplace::Agent",
    foreign_key: :user_id,
    dependent: :destroy,
    inverse_of: :user

  has_one :pharmacy, through: :agent
  has_one :current_order, through: :agent

  def create_order!
    return if current_order
    agent.orders.create!({
      state: Marketplace::Order::State::IN_PROGRESS
    })
  end
end
