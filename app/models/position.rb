class Position < ApplicationRecord
  belongs_to :ship

  attr_accessor :previous_time

  include TimeValidations
  include PositionValidations

  scope :last_positions, ->(limit = 2) { order(time: :desc).limit(limit) }
  scope :select_latest_for_each_ship, -> {
    select('
      DISTINCT ON (positions.ship_id)
      positions.time as last_time,
      positions.status as last_status,
      positions.speed as last_speed,
      positions.position as last_position,
      positions.ship_id as ship_id
    ')
      .order(:ship_id, time: :desc)
  }
end
