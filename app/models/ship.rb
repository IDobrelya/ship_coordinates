class Ship < ApplicationRecord
  has_many :positions, dependent: :destroy

  validates :id, format: {
    with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i,
    message: 'id should be valid UUID'
  }

  def last_position
    positions.last_positions&.first
  end
end
