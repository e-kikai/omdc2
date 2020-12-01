class AlterContactsIp < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :allow_mail, :boolean, default: true
    add_column :contacts, :ip,         :string,  default: ""
    add_column :contacts, :host,       :string,  default: ""
    add_column :contacts, :ua,         :string,  default: ""

    change_column :detail_logs, :ip,   :string, default: ""
    change_column :detail_logs, :host, :string, default: ""
    change_column :detail_logs, :ua,   :string, default: ""
  end
end
