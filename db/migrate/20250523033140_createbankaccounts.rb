class Createbankaccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.alias :string
      t.cvu :integer
      t.balance :integer
    end
  end