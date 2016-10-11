class ProductsAddColumn03 < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :area_id,   :integer

  end
end
