class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :product, index: true

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end
end
