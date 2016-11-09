class ProductsAddDisplay < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :display, :integer
  end
end
