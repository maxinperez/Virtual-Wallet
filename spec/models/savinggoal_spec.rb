require_relative '../spec_helper'

RSpec.describe SavingGoal, type: :model do
  let(:user) do
    unique = SecureRandom.hex(5)
    User.create!(
      dni: "12345678#{unique}",
      email: "user#{unique}@example.com",
      name: "Juan",
      last_name: "Perez",
      phone: "123456789",
      locality: "Ciudad",
      cp: "1000",
      address: "Calle Falsa 123"
    )
  end

  let(:bank_account) do
    BankAccount.create!(
      user: user,
      alias: "alias.#{SecureRandom.hex(3)}",
      cvu: "#{rand(10**21..10**22 - 1)}",
      balance: 1000.0
    )
  end

  let(:valid_attributes) do
    {
      bank_account: bank_account,
      name: "Viaje",
      target_amount: 500.0,
      saved_amount: 100.0
    }
  end

  it 'es válido con atributos válidos' do
    goal = SavingGoal.new(valid_attributes)
    expect(goal).to be_valid
  end

  it 'no es válido sin nombre' do
    goal = SavingGoal.new(valid_attributes.merge(name: nil))
    expect(goal).not_to be_valid
    expect(goal.errors[:name]).to include("can't be blank")
  end

  it 'no es válido si el monto objetivo no es positivo' do
    goal = SavingGoal.new(valid_attributes.merge(target_amount: -50))
    expect(goal).not_to be_valid
    expect(goal.errors[:target_amount]).to include("must be greater than 0")
  end

  it 'no es válido si el monto ahorrado es negativo' do
    goal = SavingGoal.new(valid_attributes.merge(saved_amount: -10))
    expect(goal).not_to be_valid
    expect(goal.errors[:saved_amount]).to include("must be greater than or equal to 0")
  end

  describe '#reached?' do
    it 'retorna true si el monto ahorrado es mayor o igual al objetivo' do
      goal = SavingGoal.new(valid_attributes.merge(saved_amount: 500))
      expect(goal.reached?).to be true
    end

    it 'retorna false si el monto ahorrado es menor al objetivo' do
      goal = SavingGoal.new(valid_attributes.merge(saved_amount: 100))
      expect(goal.reached?).to be false
    end
  end

  describe '#progress' do
    it 'retorna el porcentaje correcto del progreso' do
      goal = SavingGoal.new(valid_attributes)
      expect(goal.progress).to eq(20.0)
    end

    it 'no supera el 100%' do
      goal = SavingGoal.new(valid_attributes.merge(saved_amount: 600))
      expect(goal.progress).to eq(100.0)
    end
  end

  describe '#deposit' do
    it 'incrementa el monto ahorrado y descuenta del balance de la cuenta' do
      goal = SavingGoal.create!(valid_attributes)
      expect {
        goal.deposit(200)
      }.to change { goal.reload.saved_amount }.by(200)
         .and change { bank_account.reload.balance }.by(-200)
    end

    it 'lanza error si el monto es inválido' do
      goal = SavingGoal.create!(valid_attributes)
      expect {
        goal.deposit(0)
      }.to raise_error("Monto inválido")
    end

    it 'lanza error si no hay saldo suficiente en la cuenta' do
      bank_account.update!(balance: 50)
      goal = SavingGoal.create!(valid_attributes)
      expect {
        goal.deposit(100)
      }.to raise_error("Saldo insuficiente")
    end
  end

  describe '#withdraw' do
    it 'reduce el monto ahorrado y aumenta el balance de la cuenta' do
      goal = SavingGoal.create!(valid_attributes.merge(saved_amount: 300))
      expect {
        goal.withdraw(100)
      }.to change { goal.reload.saved_amount }.by(-100)
         .and change { bank_account.reload.balance }.by(100)
    end

    it 'lanza error si el monto es inválido' do
      goal = SavingGoal.create!(valid_attributes)
      expect {
        goal.withdraw(0)
      }.to raise_error("Monto inválido")
    end

    it 'lanza error si el monto es mayor al ahorrado' do
      goal = SavingGoal.create!(valid_attributes.merge(saved_amount: 100))
      expect {
        goal.withdraw(200)
      }.to raise_error("No hay suficiente dinero ahorrado")
    end
  end
end
