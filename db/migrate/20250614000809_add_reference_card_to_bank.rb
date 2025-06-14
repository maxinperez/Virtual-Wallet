class AddReferenceCardToBank < ActiveRecord::Migration[8.0]
  def change
    add_reference :cards, :bank_account, foreign_key: true
  end
end
