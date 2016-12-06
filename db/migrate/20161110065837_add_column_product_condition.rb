class AddColumnProductCondition < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :condition, :text
  end
end
