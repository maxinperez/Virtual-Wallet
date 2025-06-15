class Transfer < Transaction
  before_create :generate_codes

  validates :motivo, presence: true

  private

  def generate_codes
    self.transfer_code = generate_unique_code(prefix: "TRF")
    self.comprobante_code = generate_unique_code(prefix: "CBT")
  end

  def generate_unique_code(prefix:)
    loop do
      code = "#{prefix}-#{SecureRandom.hex(4).upcase}"  #por ejemplo TRF-A1B2C3D4
      unless Transfer.exists?(transfer_cod: code) || Transfer.exists?(comprobante_cod: code)
        # si se repite... 
        break code
      end
    end
  end
end