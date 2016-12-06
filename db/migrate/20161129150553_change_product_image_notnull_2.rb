class ChangeProductImageNotnull2 < ActiveRecord::Migration[5.0]
  def change
    change_column :product_images, :image, :text, null: true
  end
end
