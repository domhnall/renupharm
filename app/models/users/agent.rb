class Users::Agent < User
  has_one :agent, class_name: "Marketplace::Agent", foreign_key: :user_id
  has_one :pharmacy, through: :agent
end
