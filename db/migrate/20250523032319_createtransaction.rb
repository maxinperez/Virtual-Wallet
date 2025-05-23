class Createtransaction < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :sender_bank_account, foreign_key: { to_table: :bank_accounts }
      t.references :receiver_bank_account, foreign_key: { to_table: :bank_accounts }
      t.decimal :amount, precision: 15, scale: 2
      t.datetime :transaction_date
      t.text :description
      t.timestamps
    end
  end