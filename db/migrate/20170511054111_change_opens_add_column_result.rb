class ChangeOpensAddColumnResult < ActiveRecord::Migration[5.0]
  def change
    add_column :opens, :result, :boolean, null: false, default: false
  end
end
