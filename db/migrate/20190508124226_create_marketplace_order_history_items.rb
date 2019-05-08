class CreateMarketplaceOrderHistoryItems < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_order_history_items do |t|
      t.belongs_to :marketplace_order, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :from_state
      t.string :to_state
      t.timestamps
    end
  end
end
