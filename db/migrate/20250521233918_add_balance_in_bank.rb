class AddBalanceInBank < ActiveRecord::Migration[8.0]
  def change
    add_column :bankaccounts, :balance, :integer
  end
end
