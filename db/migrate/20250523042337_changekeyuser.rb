class Changekeyuser < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounts, :user, :string
    add_reference :accounts, :user, null: false, foreign_key: true
  end
end
