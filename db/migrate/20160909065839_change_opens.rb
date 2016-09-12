class ChangeOpens < ActiveRecord::Migration[5.0]
  def change
    change_column :opens, :name,  :string, null: false, default: ""
    change_column :opens, :owner, :string, null: false, default: "大阪機械団地組合"

    change_column :opens, :entry_start_date,     :date, null: false
    change_column :opens, :entry_end_date,       :date, null: false
    change_column :opens, :carry_in_start_date,  :date, null: false
    change_column :opens, :carry_in_end_date,    :date, null: false
    change_column :opens, :preview_start_date,   :date, null: false
    change_column :opens, :preview_end_date,     :date, null: false
    change_column :opens, :bid_start_at,         :datetime, null: false
    change_column :opens, :bid_end_at,           :datetime, null: false
    change_column :opens, :user_bid_end_at,      :datetime, null: false
    change_column :opens, :carry_out_start_date, :date, null: false
    change_column :opens, :carry_out_end_date,   :date, null: false
    change_column :opens, :billing_date,         :date, null: false
    change_column :opens, :payment_date,         :date, null: false

    change_column :opens, :lower_price, :integer, default: 20000
    change_column :opens, :rate,        :integer, default: 1000
    change_column :opens, :tax,         :integer, default: 8
  end
end
