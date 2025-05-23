class AddFieldsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :logins, :email, :string
  end
end
