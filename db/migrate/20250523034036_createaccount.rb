class Createaccount < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :user, null: false
      t.string :password_digest, null: false 
  end
end
end
