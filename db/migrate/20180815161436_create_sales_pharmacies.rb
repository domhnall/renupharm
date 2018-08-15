class CreateSalesPharmacies < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_pharmacies do |t|
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :telephone

      t.timestamps
    end
  end
end
