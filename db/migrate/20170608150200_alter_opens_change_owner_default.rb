class AlterOpensChangeOwnerDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :opens, :owner, :string, null: false, default: "大阪機械卸業団地協同組合"
  end
end
