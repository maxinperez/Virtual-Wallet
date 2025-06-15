class AddAdmin < ActiveRecord::Migration[8.0]
  def change
    add_column :admin, :username, :integer
  end
end
