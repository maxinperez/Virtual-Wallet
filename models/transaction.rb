class Transaction < ActiveRecord::Base
  belongs_to :sender_bank_account, class_name: 'BankAccount'
  belongs_to :receiver_bank_account, class_name: 'BankAccount'
end