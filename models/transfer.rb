class Transfer < Transaction
  validates :motivo, presence: true
end