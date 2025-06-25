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
let(:target_account) { BankAccount.create!(balance: 50.0, user: user) }
let(:transaction_deposit) { Transaction.create!(target_account: target_account, amount: 100.0, transaction_type: "deposit", state: "pending") }
let(:transaction_withdrawal) {Transaction.create!(target_account: target_account, amount: 30.0, transaction_type: "withdrawal", state: "pending")}
 it 'cliente solicita un deposito y admin lo valida' do
  expect(transaction_deposit).to be_valid
  expect(target_account.balance).to eq(50.0)
  transaction_deposit.update(state: "success")
  expect(target_account.balance).to eq(150.0)
 end

 it 'cliente solicita un deposito y admin lo rechaza' do
  expect(transaction_deposit).to be_valid
  expect(target_account.balance).to eq(50.0)
  transaction_deposit.update(state: "rejected")
  expect(target_account.balance).to eq(50.0)
 end

  it 'cliente solicita un retiro y admin lo valida' do
    expect(transaction_withdrawal).to be_valid
    expect(target_account.balance).to eq(50.0)
    transaction_withdrawal.update(state: "success")
    expect(target_account.balance).to eq(20.0)
  end
  it 'cliente solicita un retiro y admin lo rechaza' do
    withdrawal = Transaction.create!(target_account: target_account, amount: 30.0, transaction_type: "withdrawal", state: "pending")
    expect(transaction_withdrawal).to be_valid
    expect(target_account.balance).to eq(50.0)
    transaction_withdrawal.update(state: "rejected")
    expect(target_account.balance).to eq(50.0)
  end

end