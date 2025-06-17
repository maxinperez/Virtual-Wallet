class AddCodesToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :transfer_cod, :string
    add_column :transactions, :comprobante_cod, :string
  end
end
