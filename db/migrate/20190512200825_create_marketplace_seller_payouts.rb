class CreateMarketplaceSellerPayouts < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_seller_payouts do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :total_cents
      t.string :currency_code
      t.timestamps
    end
  end
end
