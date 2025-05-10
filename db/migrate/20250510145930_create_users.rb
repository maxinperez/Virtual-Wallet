class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    drop_table :users, if_exists: true rescue nil
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.integer :dni 
      t.string :email 
      t.string :situacion
      t.string :localidad 
      t.integer :cp 
      t.timestamps
    end
  end
end
