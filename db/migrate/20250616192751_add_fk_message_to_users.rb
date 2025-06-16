class AddFkMessageToUsers < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :messages, :accounts
    add_index :messages, :user_id
  end
end
