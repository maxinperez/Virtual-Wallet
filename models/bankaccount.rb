require 'securerandom'
class Bankaccount < ActiveRecord::Base
  
  def initialize(attributes = {})
    super(attributes) 

    self.balance ||= 0.0
    self.alias ||= generate_random_alias
    self.account_number ||= generate_random_account_number
    
  end

  belongs_to :user, foreign_key: 'dni', primary_key: 'dni'
  #contiene varias transacciones y sus origenes. 
  has_many :source_transactions, class_name: 'Transaction', foreign_key: 'source_account_id'
  validates :account_number, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :alias, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :dni, presence: true

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