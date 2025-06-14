class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'BankAccount', foreign_key: 'source_account_id', optional: true
  belongs_to :target_account, class_name: 'BankAccount', foreign_key: 'target_account_id', optional: false
  has_one :transfer, dependent: :destroy # se borra en cascada
  attribute :transaction_type, :integer
  attribute :state, :integer

  enum :transaction_type, {
    deposit: 0,
    withdrawal: 1,
    transfer: 2,
    purchase: 3
  }

  enum :state, {
    success: 0,
    pending: 1,
    rejected: 2
  }
    

  validates :amount, presence: true, numericality: { greater_than: 0 }
  #validates :state, presence: true
  #el generar un id no hace falta, active record lo hace automaticamente en la base de datos.
  before_create :process_transaction


  def self.withdraws_and_deposit_pending
    where('transaction_type = ? OR transaction_type = ?', 0, 1)
  end

  def self.flujo_dinero
    transactions = Transaction.all
    amount = 0
    transactions.each do |t|
      amount += t.amount
    end
    amount.abs
  end

  private

  def process_transaction
    ActiveRecord::Base.transaction do
      if transaction_type == "deposit" 
        target_account.update!(balance: target_account.balance + amount)
        return
      end

      if transaction_type == "withdrawal" 
        target_account.update!(balance: target_account.balance - amount)
        return
      end
  
      if transaction_type == "transfer" 
        if source_account.balance < amount
          puts "el saldo no es suficiente"
          throw(:abort)  # hace rollback si no tiene dinero la cuenta que realiza la transaccion
        end
        source_account.update!(balance: source_account.balance - amount)
        target_account.update!(balance: target_account.balance + amount)
      end
    end
  end

  def self.daily_expenses_last_month_for(user)
    where(sender_bank_account_id: user.bank_account.id)
      .where('created_at >= ?', Time.current.beginning_of_month)
      .group("DATE(created_at)")
      .sum(:amount)
  end

end
