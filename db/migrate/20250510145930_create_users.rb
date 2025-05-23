class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    drop_table :users, if_exists: true
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.integer :dni 
      t.string :email 
      t.string :situation
      t.string :locality
      t.string :address
      t.integer :cp 
      t.timestamps
    end
  end
end
