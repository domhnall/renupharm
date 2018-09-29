class AddCommentsCountColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_pharmacies, :comments_count, :integer, default: 0
    add_column :sales_contacts, :comments_count, :integer, default: 0
  end
end
