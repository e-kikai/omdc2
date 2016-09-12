class ChangeSystem < ActiveRecord::Migration[5.0]
  def change
    add_column :systems,   :email, :string, null: false, default: ""
    add_column :companies, :email, :string, null: false, default: ""
  end
end
