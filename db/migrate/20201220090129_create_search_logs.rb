class CreateSearchLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :search_logs do |t|
      t.belongs_to :user, index: true

      t.string      :ip
      t.string      :host
      t.string      :referer
      t.string      :ua
      t.string      :r,        default: "", null: false

      t.string      :path,     default: "", null: false
      t.string      :page,     default: 1,  null: false
      t.string      :keywords, default: "", null: false

      t.timestamps
    end
  end
end
