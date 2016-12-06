class ChangeProductImageNotnull < ActiveRecord::Migration[5.0]
  def change
    change_column :product_images, :image, :text, notnull: true
  end
end
