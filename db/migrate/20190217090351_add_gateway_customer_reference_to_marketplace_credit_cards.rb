class AddGatewayCustomerReferenceToMarketplaceCreditCards < ActiveRecord::Migration[5.2]
  def change
    rename_column :marketplace_credit_cards, :recurring_detail_reference, :gateway_customer_reference
  end
end
