class AddSellerPayoutIdToMarketplaceOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :marketplace_orders, :marketplace_seller_payout, foreign_key: true
  end
end
