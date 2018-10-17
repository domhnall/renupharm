class CreateMarketplaceTables < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_pharmacies do |t|
      t.string :name
      t.text :description
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :telephone
      t.string :fax
      t.string :email

      t.timestamps
    end
    add_index :marketplace_pharmacies, :name, unique: true
    add_index :marketplace_pharmacies, :email, unique: true

    create_table :marketplace_agents do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end

    create_table :marketplace_products do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.string :name
      t.text :description
      t.string :unit_size

      t.timestamps
    end
    add_index :marketplace_products, [:name, :unit_size], unique: true

    create_table :marketplace_listings do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.belongs_to :marketplace_product, foreign_key: true
      t.integer :quantity
      t.integer :price_cents
      t.date :expiry
      t.boolean :active

      t.timestamps
    end

    create_table :marketplace_orders do |t|
      t.belongs_to :marketplace_agent, foreign_key: true
      t.string :state

      t.timestamps
    end

    create_table :marketplace_line_items do |t|
      t.belongs_to :marketplace_order, foreign_key: true
      t.belongs_to :marketplace_listing, foreign_key: true

      t.timestamps
    end
  end
end
