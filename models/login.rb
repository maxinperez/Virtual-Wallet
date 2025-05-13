class Login < ActiveRecord::Base
    belongs_to :user, foreign_key: 'dni', primary_key: 'dni'
end