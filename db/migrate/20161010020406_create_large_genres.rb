class CreateLargeGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :large_genres do |t|
      t.string  :name
      t.integer :order_no
      t.belongs_to :xl_genre, index: true

      t.string :hide_option

      t.timestamps
      t.datetime    :soft_destroyed_at, index: true
    end
  end
end
