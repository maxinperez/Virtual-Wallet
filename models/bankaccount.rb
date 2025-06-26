require 'securerandom'
class BankAccount < ActiveRecord::Base
  
  # Relations
  belongs_to :user
  has_one :card
  has_many :outgoing_transactions, class_name: 'Transaction', foreign_key: 'source_account_id'
  has_many :incoming_transactions, class_name: 'Transaction', foreign_key: 'target_account_id'
  has_many :saving_goals
  
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
    all_transactions.order(created_at: :desc).limit(5)
  end

  # functions for generate account
  def generate_unique_alias
    words1 = %w[Boca River Velez Estudiantes Racing Independiente]
    words2 = %w[Cancha Estadio Predio Local Visitante Gimnasio Barra]
    loop do
      random_alias = "#{words1.sample}.#{words2.sample}.#{rand(100..999)}"
      break random_alias unless BankAccount.exists?(alias: random_alias)
    end
  end

  def generate_unique_cvu
    loop do
    random_cvu = "0600" + Array.new(18) { rand(0..9) }.join 
    break random_cvu unless BankAccount.exists?(cvu: random_cvu)
    end
  end

  def all_transactions
    Transaction.where(
      "source_account_id = :id OR target_account_id = :id",
      id: self.id
    )
  end
  

  def revenue
    all_transactions.where(transaction_type:[0,2], state: 0, target_account_id: self.id).sum(:amount)
  end
  
  def spends
    all_transactions.where(state: 0, transaction_type: [1, 2], source_account_id: self.id).sum(:amount)
  end

  def frequent_recipients(limit = 3)
    Transaction
      .where("transactions.source_account_id = ?", self.id)
      .joins("INNER JOIN bank_accounts ON bank_accounts.id = transactions.target_account_id")
      .joins("INNER JOIN users ON users.id = bank_accounts.user_id")
      .select('users.name, users.last_name, users.email, bank_accounts.id as account_id')
      .group('users.id, bank_accounts.id')
      .order('count(transactions.id) DESC')
      .limit(limit)
      .map do |t|
        {
          name: "#{t.name} #{t.last_name}",
          email: t.email,
          initials: "#{t.name[0]}#{t.last_name[0]}",
          account_id: t.account_id
        }
      end
  end

end