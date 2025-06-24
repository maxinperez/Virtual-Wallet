require_relative '../spec_helper'
require 'securerandom'

RSpec.describe Account, type: :model do
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
      username: "user#{rand(1000)}",
      password: "12345678"
    }
  end

  it 'es válido con atributos válidos' do
    account = Account.new(valid_attributes)
    expect(account).to be_valid
  end

  it 'no es válido sin username' do
    account = Account.new(valid_attributes.merge(username: nil))
    expect(account).not_to be_valid
    expect(account.errors[:username]).to include("can't be blank")
  end

  it 'no permite username repetido' do
    Account.create!(valid_attributes)
    account2 = Account.new(valid_attributes.merge(username: valid_attributes[:username]))
    expect(account2).not_to be_valid
    expect(account2.errors[:username]).to include("has already been taken")
  end

  it 'no es válido sin password_digest' do
    account = Account.new(valid_attributes.except(:password))
    expect(account).not_to be_valid
    expect(account.errors[:password_digest]).to include("can't be blank")
  end

  describe '#authenticate' do
    let(:account) { Account.create!(valid_attributes) }
    it 'retorna true si la contraseña es correcta' do
        expect(account.authenticate('12345678')).to be true
    end

    it 'retorna false si la contraseña es incorrecta' do
        expect(account.authenticate('wrongpass')).to be false
    end

  end

  it 'pertenece a un usuario' do
    account = Account.create!(valid_attributes)
    expect(account.user).to eq(user)
  end
end
