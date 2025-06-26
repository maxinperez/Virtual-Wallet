class Message < ActiveRecord::Base
  belongs_to :account, class_name: 'Account', foreign_key: :user_id
  validates :content, presence: true
  end