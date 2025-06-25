require_relative '../spec_helper'
require 'securerandom'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    unique = SecureRandom.hex(5)
    {
      dni: "12345678#{unique}",
      email: "user#{unique}@example.com",
      name: "Juan",
      last_name: "Perez",
      phone: "123456789",
      locality: "Ciudad",
      cp: "1000",
      address: "Calle Falsa 123"
    }
  end

  it 'es válido con atributos válidos' do
    user = User.new(valid_attributes)
    expect(user).to be_valid
  end

  it 'no es válido sin dni' do
    user = User.new(valid_attributes.merge(dni: nil))
    expect(user).not_to be_valid
    expect(user.errors[:dni]).to include("can't be blank")
  end

  it 'no permite dni repetido' do
    User.create!(valid_attributes)
    user2 = User.new(valid_attributes.merge(email: "otro#{rand(1000)}@mail.com"))
    expect(user2).not_to be_valid
    expect(user2.errors[:dni]).to include("has already been taken")
  end

  it 'no es válido sin email' do
    user = User.new(valid_attributes.merge(email: nil))
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'no permite email repetido' do
    User.create!(valid_attributes)
    user2 = User.new(valid_attributes.merge(dni: "87654321#{rand(1000)}"))
    expect(user2).not_to be_valid
    expect(user2.errors[:email]).to include("has already been taken")
  end

  it 'tiene muchos contacts dependientes' do
    user = User.create!(valid_attributes)
    expect(user.contacts).to be_an(ActiveRecord::Associations::CollectionProxy)
  end
  
end
