# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_03_083456) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "marketplace_accounts_fees", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_payment_id"
    t.string "type"
    t.decimal "amount_cents", precision: 10, scale: 2
    t.string "currency_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_payment_id"], name: "index_marketplace_accounts_fees_on_marketplace_payment_id"
  end

  create_table "marketplace_agents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_pharmacy_id"
    t.bigint "user_id"
    t.boolean "superintendent", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_pharmacy_id"], name: "index_marketplace_agents_on_marketplace_pharmacy_id"
    t.index ["user_id"], name: "index_marketplace_agents_on_user_id"
  end

  create_table "marketplace_bank_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_pharmacy_id"
    t.string "bank_name"
    t.string "bic"
    t.string "iban"
    t.index ["marketplace_pharmacy_id"], name: "index_marketplace_bank_accounts_on_marketplace_pharmacy_id"
  end

  create_table "marketplace_credit_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_pharmacy_id"
    t.string "gateway_customer_reference"
    t.string "holder_name"
    t.string "brand"
    t.string "number"
    t.integer "expiry_month"
    t.integer "expiry_year"
    t.string "email"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.index ["marketplace_pharmacy_id"], name: "index_marketplace_credit_cards_on_marketplace_pharmacy_id"
  end

  create_table "marketplace_line_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_order_id"
    t.bigint "marketplace_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_listing_id"], name: "index_marketplace_line_items_on_marketplace_listing_id"
    t.index ["marketplace_order_id"], name: "index_marketplace_line_items_on_marketplace_order_id"
  end

  create_table "marketplace_listings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_pharmacy_id"
    t.bigint "marketplace_product_id"
    t.integer "quantity"
    t.integer "price_cents"
    t.date "expiry"
    t.boolean "active", default: true
    t.datetime "purchased_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch_number"
    t.text "seller_note"
    t.index ["marketplace_pharmacy_id"], name: "index_marketplace_listings_on_marketplace_pharmacy_id"
    t.index ["marketplace_product_id"], name: "index_marketplace_listings_on_marketplace_product_id"
  end

  create_table "marketplace_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_agent_id"
    t.string "state"
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.index ["marketplace_agent_id"], name: "index_marketplace_orders_on_marketplace_agent_id"
    t.index ["reference"], name: "index_marketplace_orders_on_reference", unique: true
  end

  create_table "marketplace_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_credit_card_id"
    t.bigint "marketplace_order_id"
    t.string "renupharm_reference"
    t.string "gateway_reference"
    t.integer "amount_cents"
    t.string "currency_code"
    t.string "result_code"
    t.decimal "vat", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "gateway_response"
    t.index ["marketplace_credit_card_id"], name: "index_marketplace_payments_on_marketplace_credit_card_id"
    t.index ["marketplace_order_id"], name: "index_marketplace_payments_on_marketplace_order_id"
  end

  create_table "marketplace_pharmacies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "telephone"
    t.string "fax"
    t.string "email"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_marketplace_pharmacies_on_email", unique: true
    t.index ["name"], name: "index_marketplace_pharmacies_on_name", unique: true
  end

  create_table "marketplace_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "marketplace_pharmacy_id"
    t.string "name"
    t.string "pack_size"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "active_ingredient"
    t.string "form"
    t.decimal "strength", precision: 8, scale: 4
    t.decimal "volume", precision: 8, scale: 4
    t.string "identifier"
    t.integer "channel_size"
    t.string "manufacturer"
    t.index ["marketplace_pharmacy_id"], name: "index_marketplace_products_on_marketplace_pharmacy_id"
  end

  create_table "notification_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "profile_id"
    t.boolean "purchase_emails", default: true
    t.boolean "purchase_texts", default: true
    t.boolean "purchase_site_notifications", default: true
    t.boolean "sale_emails", default: true
    t.boolean "sale_texts", default: true
    t.boolean "sale_site_notifications", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_notification_configs_on_profile_id"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "profile_id"
    t.string "type"
    t.string "title"
    t.string "message"
    t.json "options"
    t.boolean "delivered", default: false
    t.json "gateway_response"
    t.index ["profile_id"], name: "index_notifications_on_profile_id"
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.string "first_name"
    t.string "surname"
    t.string "telephone"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accepted_terms_at"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sales_contacts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sales_pharmacy_id"
    t.string "first_name"
    t.string "surname"
    t.string "telephone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.index ["email"], name: "index_sales_contacts_on_email", unique: true
    t.index ["sales_pharmacy_id"], name: "index_sales_contacts_on_sales_pharmacy_id"
  end

  create_table "sales_pharmacies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "proprietor"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "email"
    t.string "telephone"
    t.string "fax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
  end

  create_table "survey_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sales_contact_id"
    t.boolean "question_1"
    t.boolean "question_2"
    t.boolean "question_3"
    t.boolean "question_4"
    t.string "question_5"
    t.text "additional_notes"
    t.json "full_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sales_contact_id"], name: "index_survey_responses_on_sales_contact_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "web_push_subscriptions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "profile_id"
    t.json "subscription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_web_push_subscriptions_on_profile_id"
  end

  add_foreign_key "comments", "users"
  add_foreign_key "marketplace_accounts_fees", "marketplace_payments"
  add_foreign_key "marketplace_agents", "marketplace_pharmacies"
  add_foreign_key "marketplace_agents", "users"
  add_foreign_key "marketplace_bank_accounts", "marketplace_pharmacies"
  add_foreign_key "marketplace_credit_cards", "marketplace_pharmacies"
  add_foreign_key "marketplace_line_items", "marketplace_listings"
  add_foreign_key "marketplace_line_items", "marketplace_orders"
  add_foreign_key "marketplace_listings", "marketplace_pharmacies"
  add_foreign_key "marketplace_listings", "marketplace_products"
  add_foreign_key "marketplace_orders", "marketplace_agents"
  add_foreign_key "marketplace_payments", "marketplace_credit_cards"
  add_foreign_key "marketplace_payments", "marketplace_orders"
  add_foreign_key "marketplace_products", "marketplace_pharmacies"
  add_foreign_key "notification_configs", "profiles"
  add_foreign_key "notifications", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "sales_contacts", "sales_pharmacies"
  add_foreign_key "survey_responses", "sales_contacts"
  add_foreign_key "web_push_subscriptions", "profiles"
end
