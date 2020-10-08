class OpensAddProductRate < ActiveRecord::Migration[5.2]
  def change
    add_column :opens, :product_rate, :integer, null: false, default: 1000
  end
end
