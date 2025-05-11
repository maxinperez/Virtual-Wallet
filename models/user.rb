class User < ActiveRecord::Base
     has_one :login, foreign_key: 'dni', primary_key: 'dni'
     has_many :account, foreign_key: 'dni', primary_key: 'dni' # 1-N
     validates :dni, uniqueness: true
     validates :email, uniqueness: true
end