class AddMotivoToTransactions < ActiveRecord::Migration[8.0]
  def change
     add_column :transactions, :motivo, :string
  end
end
