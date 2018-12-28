class AddCommentsCountToMarketplaceOrdersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :marketplace_orders, :comments_count, :integer, default: 0
  end
end
