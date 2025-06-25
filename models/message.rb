class Message < ActiveRecord::Base
  belongs_to :account, foreign_key: :user_id
  validates :content, presence: true
  end