class AddProductsCarryoutAt < ActiveRecord::Migration[5.0]
  def change
    add_column    :products, :carryout_at, :datetime

    remove_column :products, :jousetus
    remove_column :products, :area
    remove_column :products, :top_img
    remove_column :products, :imgs
    remove_column :products, :capacity
  end
end
