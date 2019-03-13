class AddCountryCodeColumnToMarketplaceAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :country, :integer, default: 0
  end
end
