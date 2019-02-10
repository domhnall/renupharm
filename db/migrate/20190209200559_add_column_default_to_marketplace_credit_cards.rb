class AddColumnDefaultToMarketplaceCreditCards < ActiveRecord::Migration[5.2]
  def change
    add_column :marketplace_credit_cards, :default, :boolean, default: false
  end
end
