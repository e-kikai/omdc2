class Changewatchutag < ActiveRecord::Migration[5.2]
  def change
    add_column :favorites,    :r,       :string
    add_column :favorites,    :referer, :string
    add_column :favorites,    :ip,      :string
    add_column :favorites,    :host,    :string
    add_column :favorites,    :ua,      :string

    add_column :favorites,    :utag,    :string
    add_column :detail_logs,  :utag,    :string
    add_column :search_logs,  :utag,    :string
    add_column :toppage_logs, :utag,    :string
  end
end
