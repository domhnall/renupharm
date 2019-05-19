class AddUniqueIndexToLineItemsOnOrderIdAndListingId < ActiveRecord::Migration[5.2]
  def change
    add_index :marketplace_line_items,
      [:marketplace_order_id, :marketplace_listing_id],
      unique: true,
      name: "index_line_items_on_order_id_and_listing_id"
  end
end
