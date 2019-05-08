class CreateMarketplaceOrderFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_order_feedbacks do |t|
      t.belongs_to :marketplace_order, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :rating
      t.text :message
      t.timestamps
    end
  end
end
