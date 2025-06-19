class AddTypes < ActiveRecord::Migration[8.0]
  def change
  add_column :transactions, :transaction_type, :integer
  add_column :transactions, :state, :integer
  end
end
