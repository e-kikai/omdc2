class ChangeColumnDefaultCompaniesEntryFalse < ActiveRecord::Migration[5.0]
  def change
    change_column_default :companies, :entry, false
  end
end
