class CreateXlGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :xl_genres do |t|
      t.string  :name
      t.integer :order_no

      t.timestamps
      t.datetime    :soft_destroyed_at, index: true

    end
  end
end
