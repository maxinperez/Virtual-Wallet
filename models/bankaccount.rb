require 'securerandom'
class BankAccount < ActiveRecord::Base
  
  def initialize(attributes = {})
    super(attributes) 

    self.balance ||= 0.0
    self.alias ||= generate_random_alias
    self.cvu ||= generate_random_account_number
    
  end
  # relations
  belongs_to :user
  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_bank_account_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_bank_account_id
  
  def most_recent_transactions 
     sent_transactions.order(id: :desc).limit(10)
  end
  # functions for generate account
  def generate_random_alias
        # pending implements alias with some patron example -> pepe.tenedor.123 -> (word1.word2.number(3))
    SecureRandom.alphanumeric(12).downcase  # create alias random
  end

  def generate_random_account_number
    # pending implements validation unique cvu ->  00310 + 17 randoms digits
    # loop que verifique que este cvu no esta registrado Account.exist?(cvu: cvu)
    Array.new(22) { rand(0..9) }.join  # simule cvu
  end
 
end