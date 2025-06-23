class Contact < ActiveRecord::Base
  belongs_to :user
  validates :contact, presence: true, uniqueness: true
end