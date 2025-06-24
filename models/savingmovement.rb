class SavingMovement < ActiveRecord::Base
  belongs_to :saving_goal

  enum :transaction_type, { 
    deposit: 0, 
    withdraw: 1 
  }

  validates :amount, numericality: { greater_than: 0 }
  validates :saving_goal, presence: true
  validates :transaction_type, presence: true
end
