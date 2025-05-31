class Transaction < ActiveRecord::Base
   belongs_to :source_account, class_name: 'BankAccount', foreign_key: 'sender_bank_account_id'
  belongs_to :target_account, class_name: 'BankAccount', foreign_key: 'receiver_bank_account_id'

 # enum state: { pending: 0, complete: 1, rejected: 2 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  #validates :state, presence: true
  #el generar un id no hace falta, active record lo hace automaticamente en la base de datos.
  before_create :process_transaction


  private

  def process_transaction
    ActiveRecord::Base.transaction do
      if source_account.balance < amount
        throw(:abort)  # hace rollback si no tiene dinero la cuenta que realiza la transaccion
      end
  
      source_account.update!(balance: source_account.balance - amount)
      target_account.update!(balance: target_account.balance + amount)
    end
  end

end
