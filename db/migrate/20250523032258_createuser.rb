class Createuser < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :dni, null: false
      t.string :email, null: false
      t.string :name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :locality, null: false
      t.string :cp, null: false
      t.string :address, null: false
      t.timestamps
    end
  end
end
