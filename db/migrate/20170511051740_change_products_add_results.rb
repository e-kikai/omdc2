class ChangeProductsAddResults < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :bids_count,     :integer, default: "0"
    add_column :products, :same_count,     :integer, default: "0"
    add_column :products, :success_bid_id, :integer
  end
end
