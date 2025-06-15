class AddCodesToTransfers < ActiveRecord::Migration[8.0]
  def change
    add_column :transfer, :transfer_cod, :string
    add_column :transfer, :comprobante_cod, :string
  end
end
