# login.rb
require 'bcrypt'

class Account < ActiveRecord::Base
  include BCrypt

  belongs_to :user, foreign_key: 'dni', primary_key: 'dni'

  validates :dni, presence: true, uniqueness: true
  validates :password_digest, presence: true

  def password=(new_password)
    self.password_digest = Password.create(new_password)
  end

  def authenticate(password)
    Password.new(password_digest) == password
  end
end