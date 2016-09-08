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

ActiveRecord::Schema.define(version: 20160908062736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bids", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "company_id"
    t.integer  "amount"
    t.text     "comment"
    t.integer  "sameno"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["company_id"], name: "index_bids_on_company_id", using: :btree
    t.index ["product_id"], name: "index_bids_on_product_id", using: :btree
    t.index ["soft_destroyed_at"], name: "index_bids_on_soft_destroyed_at", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "no"
    t.string   "charge"
    t.string   "representative"
    t.string   "position"
    t.string   "zip"
    t.string   "address"
    t.string   "tel"
    t.string   "fax"
    t.string   "mail"
    t.text     "memo"
    t.boolean  "entry"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "soft_destroyed_at"
    t.string   "account",                default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.index ["account", "soft_destroyed_at"], name: "index_companies_on_account_and_soft_destroyed_at", unique: true, using: :btree
    t.index ["soft_destroyed_at"], name: "index_companies_on_soft_destroyed_at", using: :btree
  end

  create_table "opens", force: :cascade do |t|
    t.string   "name"
    t.string   "owner"
    t.integer  "lower_price"
    t.integer  "rate"
    t.integer  "tax"
    t.date     "entry_start_date"
    t.date     "entry_end_date"
    t.datetime "carry_in_start_date"
    t.datetime "carry_in_end_date"
    t.date     "preview_start_date"
    t.date     "preview_end_date"
    t.datetime "bid_start_at"
    t.datetime "bid_end_at"
    t.datetime "user_bid_end_at"
    t.date     "carry_out_start_date"
    t.date     "carry_out_end_date"
    t.date     "billing_date"
    t.date     "payment_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_opens_on_soft_destroyed_at", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.integer  "open_id"
    t.integer  "company_id"
    t.integer  "list_no"
    t.integer  "app_no"
    t.string   "name"
    t.string   "maker"
    t.string   "model"
    t.string   "year"
    t.string   "spec"
    t.string   "area"
    t.integer  "min_price"
    t.text     "comment"
    t.string   "jousetus"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["company_id"], name: "index_products_on_company_id", using: :btree
    t.index ["open_id"], name: "index_products_on_open_id", using: :btree
    t.index ["soft_destroyed_at"], name: "index_products_on_soft_destroyed_at", using: :btree
  end

  create_table "systems", force: :cascade do |t|
    t.string   "name"
    t.string   "account",                default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "soft_destroyed_at"
    t.index ["account", "soft_destroyed_at"], name: "index_systems_on_account_and_soft_destroyed_at", unique: true, using: :btree
    t.index ["soft_destroyed_at"], name: "index_systems_on_soft_destroyed_at", using: :btree
  end

end
