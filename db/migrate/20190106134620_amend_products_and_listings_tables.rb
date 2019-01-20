class AmendProductsAndListingsTables < ActiveRecord::Migration[5.2]
  def change
    # Alter columns in marketplace_products table
    remove_column :marketplace_products, :description, :text
    add_column :marketplace_products, :active_ingredient, :string
    add_column :marketplace_products, :form, :string
    add_column :marketplace_products, :strength, :decimal, precision: 8, scale: 4
    add_column :marketplace_products, :volume, :decimal, precision: 8, scale: 4
    add_column :marketplace_products, :identifier, :string
    add_column :marketplace_products, :channel_size, :integer
    add_column :marketplace_products, :manufacturer, :string
    rename_column :marketplace_products, :unit_size, :pack_size

    # Alter columns in marketplace_listings table
    add_column :marketplace_listings, :batch_number, :string
    add_column :marketplace_listings, :seller_note, :text
  end
end
