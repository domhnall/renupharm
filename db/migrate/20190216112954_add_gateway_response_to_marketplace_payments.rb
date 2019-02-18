class AddGatewayResponseToMarketplacePayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :marketplace_payments, :auth_code
    add_column :marketplace_payments, :gateway_response, :json
  end
end
