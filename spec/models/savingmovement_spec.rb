require_relative '../spec_helper'

RSpec.describe SavingMovement, type: :model do
  let(:saving_goal) { SavingGoal.create!(name: "Meta 1", target_amount: 1000, saved_amount: 0, bank_account: BankAccount.first || FactoryBot.create(:bank_account)) }

  let(:valid_attributes) do
    {
      saving_goal: saving_goal,
      transaction_type: :deposit,
      amount: 100.0
    }
  end

  it 'es válido con atributos válidos' do
    movement = SavingMovement.new(valid_attributes)
    expect(movement).to be_valid
  end

  it 'no es válido sin saving_goal' do
    movement = SavingMovement.new(valid_attributes.merge(saving_goal: nil))
    expect(movement).not_to be_valid
    expect(movement.errors[:saving_goal]).to include("can't be blank")
  end

  it 'no es válido sin transaction_type' do
    movement = SavingMovement.new(valid_attributes.merge(transaction_type: nil))
    expect(movement).not_to be_valid
    expect(movement.errors[:transaction_type]).to include("can't be blank")
  end

  it 'no es válido con amount menor o igual a 0' do
    movement = SavingMovement.new(valid_attributes.merge(amount: 0))
    expect(movement).not_to be_valid
    expect(movement.errors[:amount]).to include("must be greater than 0")
  end

  it 'acepta transaction_type :deposit y :withdraw' do
    movement = SavingMovement.new(valid_attributes.merge(transaction_type: :deposit))
    expect(movement).to be_valid

    movement.transaction_type = :withdraw
    expect(movement).to be_valid
  end

end
