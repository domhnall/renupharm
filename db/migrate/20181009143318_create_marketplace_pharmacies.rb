class CreateMarketplacePharmacies < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_pharmacies do |t|
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :telephone
      t.string :email

      t.timestamps
    end
    add_index :marketplace_pharmacies, :name, unique: true
    add_index :marketplace_pharmacies, :email, unique: true
  end
end
