class AddLimitAndFrozenToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :limit, :decimal, default: 1000, null: false
    add_column :cards, :is_frozen, :boolean, default: false, null: false
  end
end
