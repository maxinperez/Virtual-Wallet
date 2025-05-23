class User < ActiveRecord::Base

  has_one :account, foreign_key: 'dni', primary_key: 'dni'
  has_one :bankaccount, foreign_key: 'dni', primary_key: 'dni'

  
  validates :dni, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, :last_name, :phone, :locality, :cp, :address, presence: true
end