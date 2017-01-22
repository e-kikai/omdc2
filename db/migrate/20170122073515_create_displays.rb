class CreateDisplays < ActiveRecord::Migration[5.0]
  def change
    create_table :displays do |t|
      t.string  :label, index: true
      t.string  :title
      t.boolean :display, default: false

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
