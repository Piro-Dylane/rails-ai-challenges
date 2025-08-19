class Challenge < ApplicationRecord
  validates :name, :module, :content, presence: true
  has_many :messages, dependent: :destroy
  # challenge.messages
end
