class Card < ActiveRecord::Base
    # relations
    has_one :bank_account, dependent: :destroy 
  
    validates :holder_name, presence: true
    validates :card_number, presence: true
    validates :exp_month, :exp_year,  presence: true
  end
