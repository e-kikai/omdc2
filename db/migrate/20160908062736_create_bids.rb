class CreateBids < ActiveRecord::Migration[5.0]
  def change
    create_table :bids do |t|
      t.belongs_to :product
      t.belongs_to :company
      t.integer    :amount
      t.text       :comment
      t.integer    :sameno

      t.timestamps
      t.datetime    :soft_destroyed_at, index: true
    end
  end
end
