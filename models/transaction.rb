require 'active_record/enum'

class Transaction < ActiveRecord::Base
  extend ActiveRecord::Enum
  belongs_to :source_account, class_name: 'BankAccount', foreign_key: 'sender_bank_account_id'
  belongs_to :target_account, class_name: 'BankAccount', foreign_key: 'receiver_bank_account_id'
  attribute :transaction_type, :integer
  attribute :state, :integer
  validates :amount, presence: true, numericality: { greater_than: 0 }

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

  #validates :state, presence: true
  #el generar un id no hace falta, active record lo hace automaticamente en la base de datos.
  before_create :process_transaction

  def flujo_dinero
    transactions = Transaction.all
    amount = 0
    transactions.each do |t|
      amount += t.amount
    end
    amount.abs
  end

def process_transaction
    return unless transaction_type == 2  # solo aplica a transferencias

    ActiveRecord::Base.transaction do
      if amount.nil? || amount <= 0
        errors.add(:amount, "Monto inválido")
        throw(:abort)
      end

      if source_account.balance < amount
        errors.add(:base, "Saldo insuficiente")
        throw(:abort)
      end

      source_account.update!(balance: source_account.balance - amount)
      target_account.update!(balance: target_account.balance + amount)
    end
end

  def self.daily_expenses_last_month_for(user)
    where(sender_bank_account_id: user.bank_account.id)
      .where('created_at >= ?', Time.current.beginning_of_month)
      .group("DATE(created_at)")
      .sum(:amount)
  end

end
