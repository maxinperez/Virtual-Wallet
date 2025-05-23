class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'Bankccount'
  belongs_to :target_account, class_name: 'Bankaccount'

  self.primary_key = 'id_transaction'
  enum state: {
    pending: 0,
    completed: 1,
    rejected: 2
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
>>>>>>> 93df53686eb0242561a0ed33ba6227c285e1723f
  validates :state, presence: true, 

  # Callback para generar ID de transacción si es necesario
  before_create :generate_transaction_id, unless: :id_transaction?

  private

  # Crea un id random a la hora de insertar en la tabla
  def generate_transaction_id
    self.id_transaction = SecureRandom.uuid if self.has_attribute?(:id_transaction)
  end

end