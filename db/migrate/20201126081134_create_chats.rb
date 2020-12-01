class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :company, index: true
      t.text       :comment, null: false

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
