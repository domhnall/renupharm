class AmendProductsTable < ActiveRecord::Migration[5.2]
  def self.up
    change_column :marketplace_products, :strength, :string
    add_column :marketplace_products, :weight, :decimal, precision: 8, scale: 4
  end

  def self.down
    drop_column :marketplace_products, :weight
    add_column :marketplace_products, :strength, :decimal, precision: 8, scale: 4
  end
end
