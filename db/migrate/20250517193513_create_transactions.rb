class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions, id: false do |t|
      t.string :id_transaction, primery_key: true
      t.integer :estado
      t.integer :monto 
      t.timestamps  
  end
end
