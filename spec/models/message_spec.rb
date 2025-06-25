# un user solicita ayuda a un admin, y un administrador le responde

require_relative '../spec_helper'

RSpec.describe Message do
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
 
let(:account_user){ Account.create!(user: user, password_digest: "user123", username: user.dni) }

let(:message_user)  { Message.create!(user_id: account_user.id, content: "Necesito ayuda con mi cuenta") }
let(:message_admin) { Message.create!(user_id:account_user.id, content: "Claro, ¿en qué puedo ayudarte?", from_admin: true) }

it 'permite mandar un mensaje al admin' do
  expect(message_user).to be_valid
  expect(message_user.from_admin).to eq(false)
  expect(message_user.content).to eq("Necesito ayuda con mi cuenta")
  expect(message_user.user_id).to eq(account_user.id)
end

it 'permite crear un mensaje de admin' do
  expect(message_admin).to be_valid
  expect(message_admin.from_admin).to eq(true)
  expect(message_admin.content).to eq("Claro, ¿en qué puedo ayudarte?")
  expect(message_admin.user_id).to eq(account_user.id)
end

it 'no recibe mensajes vacios' do 
  message = Message.new(user_id: account_user, content: "")
  expect(message).not_to be_valid
  expect(message.errors[:content]).to include("can't be blank")
end

end