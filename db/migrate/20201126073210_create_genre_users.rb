class CreateGenreUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :genre_users do |t|
      t.belongs_to :user,  index: true, foreign_key: true
      t.belongs_to :genre, index: true, foreign_key: true

      t.timestamps
    end
  end
end
