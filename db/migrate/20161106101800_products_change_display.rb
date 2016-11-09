class ProductsChangeDisplay < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :display, :integer, null: false, default: 0
  end
end
