class CreateGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :genres do |t|
      t.string  :name
      t.integer :order_no
      t.belongs_to :large_genre, index: true

      t.string  :capacity_label
      t.string  :capacity_unit
      t.string  :naming

      t.timestamps
      t.datetime    :soft_destroyed_at, index: true
     end
  end
end
