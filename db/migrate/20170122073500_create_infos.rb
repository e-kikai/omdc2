class CreateInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :infos do |t|
      t.string     :label, index: true
      t.string     :title
      t.text       :comment

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
