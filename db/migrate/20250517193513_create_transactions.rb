class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions, id: false do |t|
      t.string :id_transaction, null: false, primary_key: true
      t.datetime :date_transaction, null: false
      t.integer :state, null: false
      t.integer :amount, null: false
      t.timestamps
    end
  end
end