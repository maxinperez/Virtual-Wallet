class AddStateAndChangeAmountToTransaction < ActiveRecord::Migration[8.0]
  def change
    #add_column :transactions, :state, :integer, null: false, default: 0
    change_column :transactions, :amount, :integer, null: false
  end
end
