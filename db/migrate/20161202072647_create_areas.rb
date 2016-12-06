class CreateAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :areas do |t|
      t.string   :name
      t.text     :image
      t.integer  :order_no

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
