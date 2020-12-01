class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|

      t.belongs_to :user,    index: true
      t.string     :name,    null: false
      t.string     :company, null: false
      t.string     :mail,    null: false
      t.string     :tel
      t.string     :addr_1
      t.text       :content, null: false

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end
end
