require_relative '../spec_helper'

RSpec.describe Transaction do
  let(:source_account) { Account.create!(balance: 100.0) }
  let(:target_account) { Account.create!(balance: 50.0) }

  context 'validations' do
    it 'no permite crear transacción si no hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        amount: 150.0
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:base]).to include("No hay saldo suficiente en la cuenta origen para esta transacción")
    end

    it 'permite crear transacción si hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
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
        amount: 40.0
      )

      expect(source_account.reload.balance).to eq(60.0)
      expect(target_account.reload.balance).to eq(90.0)
    end
  end
end