class CreateProductImages < ActiveRecord::Migration[5.0]
  def change
    create_table :product_images do |t|
      t.belongs_to :product, null: false
      t.text       :image,   null: false
      t.integer    :order_no

      t.timestamps
    end
  end
end
