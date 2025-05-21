class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'Account'
  belongs_to :target_account, class_name: 'Account'

  self.primary_key = 'id_transaction'
  enum estado: {
    pendiente: 0,
    completada: 1,
    rechazada: 2
  }

  validates :monto, presence: true, numericality  { greater_than: 0 }
  validates :estado, presence: true, 

  # Callback para generar ID de transacción si es necesario
  before_create :generate_transaction_id, unless: :id_transaction?

  private

  # Crea un id random a la hora de insertar en la tabla
  def generate_transaction_id
    self.id_transaction = SecureRandom.uuid if self.has_attribute?(:id_transaction)
  end

end