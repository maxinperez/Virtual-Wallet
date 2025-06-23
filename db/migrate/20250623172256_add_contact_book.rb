class AddContactBook < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :contact, null: false
    end
  end
end
