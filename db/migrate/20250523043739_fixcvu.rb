class Fixcvu < ActiveRecord::Migration[8.0]
  def change
    change_column :bank_accounts, :cvu, :string
  end
end
