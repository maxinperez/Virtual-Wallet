class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.text :content
      t.boolean :from_admin, default: false
      t.timestamps
    end
  end
end
