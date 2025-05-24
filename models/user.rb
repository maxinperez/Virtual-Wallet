class User < ActiveRecord::Base
  # relations
  has_one :account, dependent: :destroy # each account has its own login details
  has_one :bank_account, dependent: :destroy  # each account has its bank account

  validates :dni, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, :last_name, :phone, :locality, :cp, :address, presence: true
end