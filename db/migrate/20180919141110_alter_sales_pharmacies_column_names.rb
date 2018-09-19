class AlterSalesPharmaciesColumnNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :sales_pharmacies, :telephone_1, :telephone
    rename_column :sales_pharmacies, :telephone_2, :fax
  end
end
