class Ship < ApplicationRecord
  has_many :positions, dependent: :destroy

  def last_positions
    positions.last_positions
  end

  def last_speed
    last_positions.last.speed
  end

  def last_time
    last_positions.last.time
  end

  def last_status
    last_positions.last.status
  end

  def last_position
    last_positions.last.position
  end
end
