class Position < ApplicationRecord
  belongs_to :ship

  scope :last_positions, ->(limit = 2) { order(time: :desc).limit(limit) }
end
