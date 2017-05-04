class ChangeProdcutGenreIdRequite < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :genre_id,   :integer, null: false, default: 390
    change_column :products, :company_id, :integer, null: false
    change_column :products, :open_id,    :integer, null: false
  end
end
