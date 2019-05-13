class Users::Admin < User
  has_many :seller_payouts,
    class_name: "Marketplace::SellerPayout",
    foreign_key: :user_id,
    inverse_of: :user
end
