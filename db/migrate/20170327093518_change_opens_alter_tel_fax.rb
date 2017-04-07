class ChangeOpensAlterTelFax < ActiveRecord::Migration[5.0]
  def change
    add_column :opens, :place, :text, default: "大阪機械卸業団地協同組合 共同展示場"
    add_column :opens, :addr,  :text, default: "東大阪市本庄中2-2-38"

    add_column :opens, :tel,   :text, default: "06-6747-7528"
    add_column :opens, :fax,   :text, default: "06-6747-7529"
  end
end
