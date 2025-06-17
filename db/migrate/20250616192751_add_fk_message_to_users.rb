class AddFkMessageToUsers < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :messages, :accounts, column: :user_id
    add_index :messages, :user_id
  end
end
