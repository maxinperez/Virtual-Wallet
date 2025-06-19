require_relative '../spec_helper'

RSpec.describe Transaction do
  let(:user) { 
  User.create!(
    dni: "12345678#{rand(1000)}", 
    email: "ricardo#{rand(1000)}@example.com", 
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