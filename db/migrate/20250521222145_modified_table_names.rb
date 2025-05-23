class ModifiedTableNames < ActiveRecord::Migration[8.0]
  def change
    rename_table :accounts, :bankaccounts
    rename_table :logins, :accounts
  end
end
