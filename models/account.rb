class Account < ActiveRecord::Base
  
  belongs_to :user, foreign_key: 'dni', primary_key: 'dni'
  #contiene varias transacciones y sus origenes. 
  has_many :source_transactions, class_name: 'Transaction', foreign_key: 'source_account_id'
  
  validates :account_number, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :alias, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :dni, presence: true


 
end