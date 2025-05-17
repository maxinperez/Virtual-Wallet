class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name :'Account'
  belongs_to :target_account, class_name :'Account'

  self.primary_key = 'id_transaction'
  enum estado: {
    pendiente: 0,
    completada: 1,
    rechazada: 2
  }

  validates :monto, presence: true, numericality  { greater_than: 0 }
  validates :estado, presence: true, 


end