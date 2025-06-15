class Wtf < ActiveRecord::Migration[8.0]
  def change
    remove_column :bank_accounts, :bank_accounts_id, :integer
  end
end
