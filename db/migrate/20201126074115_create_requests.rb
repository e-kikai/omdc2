class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :product, index: true
      t.belongs_to :company, index: true

      t.integer    :amount
      t.datetime   :bided_at

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end
end
