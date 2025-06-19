class CreateSavingGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :saving_goals do |t|
      t.references :bank_account, foreign_key: true
      t.string :name
      t.decimal :target_amount, precision: 10, scale: 2
      t.decimal :saved_amount, precision: 10, scale: 2, default: 0
      t.date :due_date

      t.timestamps
    end
  end
end
