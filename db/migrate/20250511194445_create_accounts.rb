class CreateAccounts < ActiveRecord::Migration[8.0]
  def change 
    create_table :accounts do |t|
      # agregar balance si es necesario
      t.string :account_number, null: false
      t.string :alias, null: false
      t.string :dni, null: false  # FK hacia users
      t.timestamps
    end

    # con razon no arrancaba la migracion de cuenta, los indices van por fuera del "change".
    add_index :accounts, :account_number, unique: true, name: 'unique_global_account_number'
    add_index :accounts, :alias, unique: true, name: 'unique_global_alias'
    add_index :accounts, :dni
  end
end
