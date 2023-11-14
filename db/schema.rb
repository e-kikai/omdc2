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

ActiveRecord::Schema.define(version: 2023_11_13_052021) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.integer "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_areas_on_soft_destroyed_at"
  end

  create_table "bids", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "company_id"
    t.integer "amount"
    t.text "comment"
    t.integer "sameno", default: -> { "round((random() * (2000000000)::double precision))" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "charge"
    t.index ["company_id"], name: "index_bids_on_company_id"
    t.index ["product_id"], name: "index_bids_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_bids_on_soft_destroyed_at"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["company_id"], name: "index_chats_on_company_id"
    t.index ["soft_destroyed_at"], name: "index_chats_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "no"
    t.string "charge"
    t.string "representative"
    t.string "position"
    t.string "zip"
    t.string "address"
    t.string "tel"
    t.string "fax"
    t.string "mail"
    t.text "memo"
    t.boolean "entry", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "account", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "email", default: "", null: false
    t.boolean "transfer", default: false
    t.string "registration_number", default: "", null: false
    t.index ["account", "soft_destroyed_at"], name: "index_companies_on_account_and_soft_destroyed_at", unique: true
    t.index ["no", "soft_destroyed_at"], name: "index_companies_on_no_and_soft_destroyed_at", unique: true
    t.index ["soft_destroyed_at"], name: "index_companies_on_soft_destroyed_at"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "company", null: false
    t.string "mail", null: false
    t.string "tel"
    t.string "addr_1"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.boolean "allow_mail", default: true
    t.string "ip", default: ""
    t.string "host", default: ""
    t.string "ua", default: ""
    t.index ["soft_destroyed_at"], name: "index_contacts_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "detail_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.string "ip", default: ""
    t.string "host", default: ""
    t.string "ua", default: ""
    t.string "referer"
    t.string "r", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utag"
    t.index ["product_id"], name: "index_detail_logs_on_product_id"
    t.index ["user_id"], name: "index_detail_logs_on_user_id"
  end

  create_table "displays", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "title"
    t.boolean "display", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["label"], name: "index_displays_on_label"
    t.index ["soft_destroyed_at"], name: "index_displays_on_soft_destroyed_at"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.integer "amount"
    t.string "r"
    t.string "referer"
    t.string "ip"
    t.string "host"
    t.string "ua"
    t.string "utag"
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_favorites_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "genres", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "order_no"
    t.integer "large_genre_id"
    t.string "capacity_label"
    t.string "capacity_unit"
    t.string "naming"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["large_genre_id"], name: "index_genres_on_large_genre_id"
    t.index ["soft_destroyed_at"], name: "index_genres_on_soft_destroyed_at"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "order_no", default: 9999999, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_industries_on_soft_destroyed_at"
  end

  create_table "industry_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "industry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_industry_users_on_industry_id"
    t.index ["user_id"], name: "index_industry_users_on_user_id"
  end

  create_table "infos", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["label"], name: "index_infos_on_label"
    t.index ["soft_destroyed_at"], name: "index_infos_on_soft_destroyed_at"
  end

  create_table "large_genre_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "large_genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["large_genre_id"], name: "index_large_genre_users_on_large_genre_id"
    t.index ["user_id"], name: "index_large_genre_users_on_user_id"
  end

  create_table "large_genres", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "order_no"
    t.integer "xl_genre_id"
    t.string "hide_option"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_large_genres_on_soft_destroyed_at"
    t.index ["xl_genre_id"], name: "index_large_genres_on_xl_genre_id"
  end

  create_table "name2gnre_id_temp", id: false, force: :cascade do |t|
    t.text "name"
    t.integer "genre_id"
  end

  create_table "opens", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "owner", default: "大阪機械卸業団地協同組合", null: false
    t.integer "lower_price", default: 20000
    t.integer "rate", default: 1000
    t.integer "tax", default: 8
    t.date "entry_start_date", null: false
    t.date "entry_end_date", null: false
    t.date "carry_in_start_date", null: false
    t.date "carry_in_end_date", null: false
    t.date "preview_start_date", null: false
    t.date "preview_end_date", null: false
    t.datetime "bid_start_at", null: false
    t.datetime "bid_end_at", null: false
    t.datetime "user_bid_end_at", null: false
    t.date "carry_out_start_date", null: false
    t.date "carry_out_end_date", null: false
    t.date "billing_date", null: false
    t.date "payment_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.text "place", default: "大阪機械卸業団地協同組合 共同展示場", null: false
    t.text "addr", default: "東大阪市本庄中2-2-38", null: false
    t.text "tel", default: "06-6747-7528", null: false
    t.text "fax", default: "06-6747-7529", null: false
    t.boolean "result", default: false, null: false
    t.integer "product_rate", default: 1000, null: false
    t.index ["soft_destroyed_at"], name: "index_opens_on_soft_destroyed_at"
  end

  create_table "product_images", id: :serial, force: :cascade do |t|
    t.integer "product_id", null: false
    t.text "image"
    t.integer "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.integer "open_id", null: false
    t.integer "company_id", null: false
    t.integer "list_no"
    t.integer "app_no"
    t.string "name"
    t.string "maker"
    t.string "model"
    t.string "year"
    t.string "spec"
    t.integer "min_price"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.integer "genre_id", default: 390, null: false
    t.string "accessory"
    t.string "pdfs"
    t.string "youtube"
    t.integer "area_id"
    t.integer "display", default: 0, null: false
    t.text "condition"
    t.boolean "hitoyama", default: false
    t.datetime "carryout_at"
    t.integer "bids_count", default: 0
    t.integer "same_count", default: 0
    t.integer "success_bid_id"
    t.boolean "featured", default: false, null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["open_id"], name: "index_products_on_open_id"
    t.index ["soft_destroyed_at"], name: "index_products_on_soft_destroyed_at"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.bigint "company_id"
    t.integer "amount"
    t.datetime "bided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["company_id"], name: "index_requests_on_company_id"
    t.index ["product_id"], name: "index_requests_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_requests_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "search_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "ip"
    t.string "host"
    t.string "referer"
    t.string "ua"
    t.string "r", default: "", null: false
    t.string "path", default: "", null: false
    t.string "page", default: "1", null: false
    t.string "keywords", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utag"
    t.index ["user_id"], name: "index_search_logs_on_user_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "systems", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "account", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "email", default: "", null: false
    t.index ["account", "soft_destroyed_at"], name: "index_systems_on_account_and_soft_destroyed_at", unique: true
    t.index ["soft_destroyed_at"], name: "index_systems_on_soft_destroyed_at"
  end

  create_table "toppage_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "ip"
    t.string "host"
    t.string "referer"
    t.string "ua"
    t.string "r", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utag"
    t.index ["user_id"], name: "index_toppage_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "company", null: false
    t.boolean "allow_mail", default: true
    t.string "tel"
    t.string "fax"
    t.string "zip"
    t.string "addr"
    t.bigint "window_id"
    t.datetime "soft_destroyed_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["soft_destroyed_at"], name: "index_users_on_soft_destroyed_at"
    t.index ["window_id"], name: "index_users_on_window_id"
  end

  create_table "xl_genres", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_xl_genres_on_soft_destroyed_at"
  end

  add_foreign_key "industry_users", "industries"
  add_foreign_key "industry_users", "users"
  add_foreign_key "large_genre_users", "genres", column: "large_genre_id"
  add_foreign_key "large_genre_users", "users"
end
