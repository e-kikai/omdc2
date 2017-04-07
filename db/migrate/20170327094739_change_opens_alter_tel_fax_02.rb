class ChangeOpensAlterTelFax02 < ActiveRecord::Migration[5.0]
  def change
    change_column :opens, :place, :text, null: false, default: "大阪機械卸業団地協同組合 共同展示場"
    change_column :opens, :addr,  :text, null: false, default: "東大阪市本庄中2-2-38"

    change_column :opens, :tel,   :text, null: false, default: "06-6747-7528"
    change_column :opens, :fax,   :text, null: false, default: "06-6747-7529"

  end
end
