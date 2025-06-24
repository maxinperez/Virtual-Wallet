require_relative '../spec_helper'
require 'securerandom'

RSpec.describe BankAccount, type: :model do
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

  let(:valid_attributes) do
    {
      user: user,
      alias: "alias.#{rand(1000)}",
      cvu: "#{rand(10**21..10**22 - 1)}",
      balance: 1000.0
    }
  end

  it 'es válido con atributos válidos' do
    bank_account = BankAccount.new(valid_attributes)
    expect(bank_account).to be_valid
  end

  it 'no es válido sin alias' do
    bank_account = BankAccount.new(valid_attributes.except(:alias))
    allow(bank_account).to receive(:ensure_unique_alias_and_cvu) # bloquea el callback
    bank_account.validate
    expect(bank_account.errors[:alias]).to include("can't be blank")
  end


  it 'no permite alias repetido' do
    BankAccount.create!(valid_attributes)
    bank_account2 = BankAccount.new(valid_attributes.merge(cvu: "#{rand(10**21..10**22 - 1)}"))
    expect(bank_account2).not_to be_valid
    expect(bank_account2.errors[:alias]).to include("has already been taken")
  end

  it 'no es válido sin cvu' do
    bank_account = BankAccount.new(valid_attributes.except(:cvu))
    allow(bank_account).to receive(:ensure_unique_alias_and_cvu) # evita que lo genere
    bank_account.validate
    expect(bank_account.errors[:cvu]).to include("can't be blank")
  end


  it 'no permite cvu repetido' do
    BankAccount.create!(valid_attributes)
    bank_account2 = BankAccount.new(valid_attributes.merge(alias: "alias2.#{rand(1000)}"))
    expect(bank_account2).not_to be_valid
    expect(bank_account2.errors[:cvu]).to include("has already been taken")
  end

  it 'genera alias automáticamente si no se proporciona' do
    bank_account = BankAccount.create!(valid_attributes.except(:alias))
    expect(bank_account.alias).to be_present
  end

  it 'genera cvu automáticamente si no se proporciona' do
    bank_account = BankAccount.create!(valid_attributes.except(:cvu))
    expect(bank_account.cvu).to be_present
  end


  it 'pertenece a un usuario' do
    bank_account = BankAccount.create!(valid_attributes)
    expect(bank_account.user).to eq(user)
  end

  it 'tiene muchos saving_goals' do
    bank_account = BankAccount.create!(valid_attributes)
    expect(bank_account.saving_goals).to be_an(ActiveRecord::Associations::CollectionProxy)
  end
end
