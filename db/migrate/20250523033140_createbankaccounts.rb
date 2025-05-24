class Createbankaccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.references :bank_accounts, :user, null: false, foreign_key: true
      t.string :alias
      t.integer :cvu
      t.decimal :balance
    end
  end
end