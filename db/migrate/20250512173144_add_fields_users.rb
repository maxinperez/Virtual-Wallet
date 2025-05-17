class AddFieldsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :direccion, :string
    remove_column :users, :email, :string
    add_column :logins, :email, :string
  end
end
