class Addaccesslog < ActiveRecord::Migration[8.0]
  def change
     create_table :access_logs do |t| 
       t.string :ip_address, null: false
       t.references :account, null: false, foreign_key: true
       t.timestamps
     end
    end 
end
