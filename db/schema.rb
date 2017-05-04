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

ActiveRecord::Schema.define(version: 20170504125416) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string   "name"
    t.text     "image"
    t.integer  "order_no"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_areas_on_soft_destroyed_at", using: :btree
  end

  create_table "bids", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "company_id"
    t.integer  "amount"
    t.text     "comment"
    t.integer  "sameno",            default: -> { "round((random() * (2000000000)::double precision))" }
    t.datetime "created_at",                                                                              null: false
    t.datetime "updated_at",                                                                              null: false
    t.datetime "soft_destroyed_at"
    t.string   "charge"
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
    t.boolean  "entry",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "soft_destroyed_at"
    t.string   "account",                default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "email",                  default: "",    null: false
    t.index ["account", "soft_destroyed_at"], name: "index_companies_on_account_and_soft_destroyed_at", unique: true, using: :btree
    t.index ["no", "soft_destroyed_at"], name: "index_companies_on_no_and_soft_destroyed_at", unique: true, using: :btree
    t.index ["soft_destroyed_at"], name: "index_companies_on_soft_destroyed_at", using: :btree
  end

  create_table "displays", force: :cascade do |t|
    t.string   "label"
    t.string   "title"
    t.boolean  "display",           default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "soft_destroyed_at"
    t.index ["label"], name: "index_displays_on_label", using: :btree
    t.index ["soft_destroyed_at"], name: "index_displays_on_soft_destroyed_at", using: :btree
  end

  create_table "genres", force: :cascade do |t|
    t.string   "name"
    t.integer  "order_no"
    t.integer  "large_genre_id"
    t.string   "capacity_label"
    t.string   "capacity_unit"
    t.string   "naming"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["large_genre_id"], name: "index_genres_on_large_genre_id", using: :btree
    t.index ["soft_destroyed_at"], name: "index_genres_on_soft_destroyed_at", using: :btree
  end

  create_table "infos", force: :cascade do |t|
    t.string   "label"
    t.string   "title"
    t.text     "comment"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["label"], name: "index_infos_on_label", using: :btree
    t.index ["soft_destroyed_at"], name: "index_infos_on_soft_destroyed_at", using: :btree
  end

  create_table "large_genres", force: :cascade do |t|
    t.string   "name"
    t.integer  "order_no"
    t.integer  "xl_genre_id"
    t.string   "hide_option"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_large_genres_on_soft_destroyed_at", using: :btree
    t.index ["xl_genre_id"], name: "index_large_genres_on_xl_genre_id", using: :btree
  end

  create_table "opens", force: :cascade do |t|
    t.string   "name",                 default: "",                   null: false
    t.string   "owner",                default: "大阪機械団地組合",           null: false
    t.integer  "lower_price",          default: 20000
    t.integer  "rate",                 default: 1000
    t.integer  "tax",                  default: 8
    t.date     "entry_start_date",                                    null: false
    t.date     "entry_end_date",                                      null: false
    t.date     "carry_in_start_date",                                 null: false
    t.date     "carry_in_end_date",                                   null: false
    t.date     "preview_start_date",                                  null: false
    t.date     "preview_end_date",                                    null: false
    t.datetime "bid_start_at",                                        null: false
    t.datetime "bid_end_at",                                          null: false
    t.datetime "user_bid_end_at",                                     null: false
    t.date     "carry_out_start_date",                                null: false
    t.date     "carry_out_end_date",                                  null: false
    t.date     "billing_date",                                        null: false
    t.date     "payment_date",                                        null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.datetime "soft_destroyed_at"
    t.text     "place",                default: "大阪機械卸業団地協同組合 共同展示場", null: false
    t.text     "addr",                 default: "東大阪市本庄中2-2-38",      null: false
    t.text     "tel",                  default: "06-6747-7528",       null: false
    t.text     "fax",                  default: "06-6747-7529",       null: false
    t.index ["soft_destroyed_at"], name: "index_opens_on_soft_destroyed_at", using: :btree
  end

  create_table "product_images", force: :cascade do |t|
    t.integer  "product_id", null: false
    t.text     "image"
    t.integer  "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.integer  "open_id",                           null: false
    t.integer  "company_id",                        null: false
    t.integer  "list_no"
    t.integer  "app_no"
    t.string   "name"
    t.string   "maker"
    t.string   "model"
    t.string   "year"
    t.string   "spec"
    t.integer  "min_price"
    t.text     "comment"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "soft_destroyed_at"
    t.integer  "genre_id",          default: 390,   null: false
    t.string   "accessory"
    t.string   "pdfs"
    t.string   "youtube"
    t.integer  "area_id"
    t.integer  "display",           default: 0,     null: false
    t.text     "condition"
    t.boolean  "hitoyama",          default: false
    t.datetime "carryout_at"
    t.index ["company_id"], name: "index_products_on_company_id", using: :btree
    t.index ["open_id"], name: "index_products_on_open_id", using: :btree
    t.index ["soft_destroyed_at"], name: "index_products_on_soft_destroyed_at", using: :btree
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
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
    t.string   "email",                  default: "", null: false
    t.index ["account", "soft_destroyed_at"], name: "index_systems_on_account_and_soft_destroyed_at", unique: true, using: :btree
    t.index ["soft_destroyed_at"], name: "index_systems_on_soft_destroyed_at", using: :btree
  end

  create_table "xl_genres", force: :cascade do |t|
    t.string   "name"
    t.integer  "order_no"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_xl_genres_on_soft_destroyed_at", using: :btree
  end

end
