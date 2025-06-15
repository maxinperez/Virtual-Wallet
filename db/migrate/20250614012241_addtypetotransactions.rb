class Addtypetotransactions < ActiveRecord::Migration[7.1]
  def change
   add_column :transactions, :transaction_type, :integer
   #add_column :transactions, :state, :integer
   end
end
