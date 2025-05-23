class AddCascade < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :accounts, :users, column: :dni, primary_key: :dni, on_delete: :cascade
  end
end
