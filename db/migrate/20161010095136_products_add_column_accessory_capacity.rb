class ProductsAddColumnAccessoryCapacity < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :capacity,  :float
    add_column :products, :accessory, :string
    add_column :products, :top_img,   :string
    add_column :products, :imgs,      :string
    add_column :products, :pdfs,      :string
    add_column :products, :youtube,   :string

    add_column :bids, :charge,   :string
  end
end
