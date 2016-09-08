class CreateOpens < ActiveRecord::Migration[5.0]
  def change
    create_table :opens do |t|
      t.string   :name
      t.string   :owner
      t.integer  :lower_price
      t.integer  :rate
      t.integer  :tax

      t.date     :entry_start_date
      t.date     :entry_end_date

      t.datetime :carry_in_start_date
      t.datetime :carry_in_end_date

      t.date     :preview_start_date
      t.date     :preview_end_date

      t.datetime :bid_start_at
      t.datetime :bid_end_at
      t.datetime :user_bid_end_at

      t.date     :carry_out_start_date
      t.date     :carry_out_end_date

      t.date     :billing_date
      t.date     :payment_date

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
