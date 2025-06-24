require_relative '../spec_helper'
require 'securerandom'

RSpec.describe Transaction do
  let(:user) { 
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
let(:source_account) { BankAccount.create!(balance: 100.0, user: user) }
let(:target_account) { BankAccount.create!(balance: 50.0, user: user) }

  context 'validations' do
    it 'no permite crear transacción si no hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        transaction_type: "transfer", 
        amount: 150.0
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:base]).to include("No hay saldo suficiente en la cuenta origen para esta transacción")
    end

    it 'permite crear transacción si hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        transaction_type: "transfer",
        amount: 50.0
      )
      expect(transaction).to be_valid
    end
  end

  context 'after create callback' do
    it 'debita y acredita los balances correctamente' do
      transaction = Transaction.create!(
        source_account: source_account,
        target_account: target_account,
        transaction_type: "transfer",
        amount: 40.0
      )

    transaction.update!(state: :success)

      expect(source_account.reload.balance).to eq(60.0)
      expect(target_account.reload.balance).to eq(90.0)
    end
  end
end