class AddAdmin < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :admin, :integer
  end
end
