class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.belongs_to :open
      t.belongs_to :company

      t.integer    :list_no
      t.integer    :app_no
      t.string     :name
      t.string     :maker
      t.string     :model
      t.string     :year
      t.string     :spec
      t.string     :area
      t.integer    :min_price
      t.text       :comment
      t.string     :jousetus

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
