class AddTypes < ActiveRecord::Migration[8.0]
  def change
  add_column :transactions, :transaction_type, :integer
  end
end
