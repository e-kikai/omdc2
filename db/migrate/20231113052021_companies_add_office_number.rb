class CompaniesAddOfficeNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :registration_number, :string, default: "", null: false
  end
end
