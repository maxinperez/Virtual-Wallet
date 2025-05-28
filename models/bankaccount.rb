require 'securerandom'
class BankAccount < ActiveRecord::Base
  
  # Relations
  belongs_to :user
  has_many :outgoing_transactions, class_name: 'Transaction', foreign_key: 'source_account_id'
  has_many :incoming_transactions, class_name: 'Transaction', foreign_key: 'target_account_id'
  
  # Validations
  validates :alias, uniqueness: true, presence: true
  validates :cvu, uniqueness: true, presence: true

  # Callbacks
  before_validation :ensure_unique_alias_and_cvu

  def ensure_unique_alias_and_cvu
    self.balance ||= 0.0
    self.alias ||= generate_unique_alias
    self.cvu ||= generate_unique_cvu
  end
  
  
  def most_recent_transactions 
     sent_transactions.order(id: :desc).limit(10)
  end
  # functions for generate account
  def generate_unique_alias
        #Debo generar un alias unico
  end

  def generate_unique_cvu
    #Debo generar un cvu unico
  end
 
end