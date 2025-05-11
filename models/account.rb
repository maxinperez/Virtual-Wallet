class Account < ActiveRecord::Base
  #la correspondencias, en un principio con user solamente.
  belongs_to :user, foreign_key: 'dni', primary_key: 'dni'

  
  validates :account_number, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :alias, presence: true, uniqueness: { message: "ya está en uso por otra cuenta" }
  validates :dni, presence: true


 
end