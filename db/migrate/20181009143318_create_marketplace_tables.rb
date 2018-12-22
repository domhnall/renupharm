class CreateMarketplaceTables < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_pharmacies do |t|
      t.string     :name
      t.text       :description
      t.string     :address_1
      t.string     :address_2
      t.string     :address_3
      t.string     :telephone
      t.string     :fax
      t.string     :email
      t.boolean    :active, default: true

      t.timestamps
    end
    add_index :marketplace_pharmacies, :name, unique: true
    add_index :marketplace_pharmacies, :email, unique: true

    create_table :marketplace_agents do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.boolean    :superintendent, default: false
      t.boolean    :active, default: true

      t.timestamps
    end

    create_table :marketplace_products do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.string     :name
      t.text       :description
      t.string     :unit_size
      t.boolean    :active, default: true

      t.timestamps
    end

    create_table :marketplace_listings do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.belongs_to :marketplace_product, foreign_key: true
      t.integer    :quantity
      t.integer    :price_cents
      t.date       :expiry
      t.boolean    :active, default: true
      t.datetime   :purchased_at

      t.timestamps
    end

    create_table :marketplace_orders do |t|
      t.belongs_to :marketplace_agent, foreign_key: true
      t.string     :state
      t.string     :reference

      t.timestamps
    end
    add_index :marketplace_orders, :reference, unique: true

    create_table :marketplace_line_items do |t|
      t.belongs_to :marketplace_order, foreign_key: true
      t.belongs_to :marketplace_listing, foreign_key: true

      t.timestamps
    end

    create_table :marketplace_credit_cards do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.string     :recurring_detail_reference
      t.string     :holder_name
      t.string     :brand
      t.string     :number
      t.integer    :expiry_month
      t.integer    :expiry_year
      t.string     :email
      t.boolean    :active, default: true

      t.timestamps
    end

    create_table :marketplace_payments do |t|
      t.belongs_to :marketplace_credit_card, foreign_key: true
      t.belongs_to :marketplace_order, foreign_key: true
      t.string     :renupharm_reference
      t.string     :gateway_reference
      t.integer    :amount_cents
      t.string     :currency_code
      t.string     :result_code
      t.string     :auth_code
      t.decimal    :vat, precision: 10, scale: 2

      t.timestamps
    end

    create_table :marketplace_accounts_fees do |t|
      t.belongs_to :marketplace_payment, foreign_key: true
      t.string     :type
      t.decimal    :amount_cents, precision: 10, scale: 2
      t.string     :currency_code

      t.timestamps
    end

    create_table :marketplace_bank_accounts do |t|
      t.belongs_to :marketplace_pharmacy, foreign_key: true
      t.string     :bank_name
      t.string     :bic
      t.string     :iban
    end
  end
end
