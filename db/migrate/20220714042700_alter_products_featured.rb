class AlterProductsFeatured < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :featured, :boolean, default: false, null: false
  end
end
