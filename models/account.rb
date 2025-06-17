# login.rb
require 'bcrypt'

class Account < ActiveRecord::Base
  include BCrypt
  has_secure_password
  belongs_to :user
  has_many :messages


  validates :username, presence: true, uniqueness: true
  validates :password_digest, presence: true

  enum :admin, {
    support: 1,
    cashier: 2,
    superadmin: 3
  }

  def password=(new_password)
    self.password_digest = Password.create(new_password)
  end

  def authenticate(password)
    Password.new(password_digest) == password
  end
end

