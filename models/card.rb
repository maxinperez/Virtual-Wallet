class Card < ActiveRecord::Base
    # relations
    belongs_to :bank_account, dependent: :destroy
  
    validates :holder_name, presence: true
    validates :card_number, presence: true, uniqueness: true
    validates :exp_month, :exp_year,  presence: true
    validates :limit, numericality: { greater_than: 0 }
    validates :is_frozen, inclusion: { in: [true, false] }

    # callbacks
    before_validation :unique_cardnumber

  def unique_cardnumber
    self.card_number ||= generate_unique_cardnumber
    self.cvv ||= generate_unique_cvv
    self.exp_month ||= 12
    self.exp_year ||= 30
    self.is_frozen = false if is_frozen.nil?
    self.limit = 1000 if limit.nil? || limit <= 0
    
  end

  def generate_unique_cardnumber
    loop do
    random_card = Array.new(18) { rand(0..9) }.join
    break random_card unless Card.exists?(card_number: random_card)
    end
  end
  def generate_unique_cvv
    random_cvv = Array.new(3) { rand(0..9) }.join
  end

  def freeze!
    update(is_frozen: true)
  end

  def unfreeze!
    update(is_frozen: false)
  end

  end
