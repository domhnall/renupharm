class CreateSalesContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_contacts do |t|
      t.references :sales_pharmacy, foreign_key: true
      t.string :first_name
      t.string :surname
      t.string :telephone
      t.string :email

      t.timestamps
    end
    add_index :sales_contacts, :email, unique: true
  end
end
