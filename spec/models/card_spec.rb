require_relative '../spec_helper'
RSpec.describe Card do
  let(:user){
  unique = SecureRandom.hex(5)
  User.create!(
    dni: "12345678#{unique}", 
    email: "ricardo#{unique}@example.com", 
    name: "pepe", 
    last_name: "gomez", 
    phone: "1234567890", 
    locality: "Ciudad", 
    cp: "1000", 
    address: "Calle Falsa 123"
    ) 
    }
    let(:bank_account) { BankAccount.create!(user: user) }
    let(:card) { Card.create(bank_account: bank_account, limit: 1000, holder_name: "Juan") }
    let(:card_with_limit_invalid) { Card.create(bank_account: bank_account, limit: -100, holder_name: "Juan")}

    it 'tarjeta con limite invalido' do
        expect(card_with_limit_invalid).not_to be_valid
    end

    it 'tarjeta con limite valido' do
        expect(card).to be_valid
    end
end