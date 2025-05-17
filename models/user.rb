class User < ActiveRecord::Base
     has_one :login, foreign_key: 'dni', primary_key: 'dni'
     has_one :account, foreign_key: 'dni', primary_key: 'dni' 
     validates :dni, uniqueness: true
     validates :email, uniqueness: true
end