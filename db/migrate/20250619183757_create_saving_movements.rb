class CreateSavingMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :saving_movements do |t|
      t.references :saving_goal, foreign_key: true, null: false
      t.integer :transaction_type, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.timestamps
    end
  end
end
