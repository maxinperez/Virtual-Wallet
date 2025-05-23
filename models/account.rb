# login.rb
require 'bcrypt'

class Account < ActiveRecord::Base
  include BCrypt
  # relations
  belongs_to :user

  # validations in model
  validates :password_digest, presence: true

  def password=(new_password)
    self.password_digest = Password.create(new_password)
  end

  def authenticate(password)
    Password.new(password_digest) == password
  end
end

