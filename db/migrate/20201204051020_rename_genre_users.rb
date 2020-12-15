class RenameGenreUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :genre_users, :large_genre_users

    rename_column :users,             :company_id, :window_id
    rename_column :large_genre_users, :genre_id,   :large_genre_id
  end
end
