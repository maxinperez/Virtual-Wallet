class CreateCard < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :holder_name
      t.string :card_number
      t.string :cvv
      t.integer :exp_month  # solo el mes
      t.integer :exp_year   # solo el año
      t.timestamps
    end
  end
end