class FavoritesAddColumnAmount < ActiveRecord::Migration[5.2]
  def change
    add_column :favorites, :amount, :integer
  end
end
