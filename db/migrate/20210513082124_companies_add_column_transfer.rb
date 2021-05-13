class CompaniesAddColumnTransfer < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :transfer, :boolean, default: false
  end
end
