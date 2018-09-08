class CreateSalesPharmacies < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_pharmacies do |t|
      t.string :name
      t.string :proprietor
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :email
      t.string :telephone_1
      t.string :telephone_2

      t.timestamps
    end
    #add_index :sales_pharmacies, [:name, :address_3], unique: true
  end
end
