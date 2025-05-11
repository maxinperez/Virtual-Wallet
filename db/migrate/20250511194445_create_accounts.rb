class CreateAccounts < ActiveRecord::Migration[8.0]
  def change 
    create_table :accounts do |t|
       t.string :account_number, null: false
       t.string :alias, null: false
       t.string :dni, null: false  # fk hacia users.
       t.timestamps
       #como se trabajaria la clave unica?
        #(evito repetición en toda la tabla)
       add_index :accounts, :account_number, unique: true, name: 'unique_global_account_number'
       add_index :accounts, :alias, unique: true, name: 'unique_global_alias'

       #búsquedas por FK (dni)
       add_index :accounts, :dni
    end
  end
end
