class ChangeBidsSameNo < ActiveRecord::Migration[5.0]
  def change
    execute "ALTER TABLE bids ALTER COLUMN sameno SET DEFAULT round(random() * 2000000000) ;"

    add_index :companies, [:no, :soft_destroyed_at], unique: true
  end
end
