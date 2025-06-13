class CreateTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :transfer do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :motivo
      t.timestamps
  end
end
end