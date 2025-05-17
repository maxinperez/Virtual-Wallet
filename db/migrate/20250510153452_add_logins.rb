class AddLogins < ActiveRecord::Migration[8.0]
  def change
    create_table :logins do |t|
      t.string :dni # campo que será la clave foránea
      t.string :password_digest
      t.timestamps
    end
     # Agregar un índice único al campo dni en la tabla users
     add_index :users, :dni, unique: true

     # Agregar la clave foránea a la tabla logins para hacer referencia a users.dni
     add_foreign_key :logins, :users, column: :dni, primary_key: :dni
     # agrego unicidad en email
end
end