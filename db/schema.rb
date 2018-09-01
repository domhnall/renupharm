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

ActiveRecord::Schema.define(version: 2018_09_01_114659) do

  create_table "sales_contacts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sales_pharmacy_id"
    t.string "first_name"
    t.string "surname"
    t.string "telephone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sales_pharmacy_id"], name: "index_sales_contacts_on_sales_pharmacy_id"
  end

  create_table "sales_pharmacies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.boolean "question_1"
    t.boolean "question_2"
    t.boolean "question_3"
    t.boolean "question_4"
    t.string "question_5"
    t.text "additional_notes"
    t.json "full_response"
  end

  add_foreign_key "sales_contacts", "sales_pharmacies"
end
