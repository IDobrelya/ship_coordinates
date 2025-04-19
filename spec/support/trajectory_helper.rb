module TestHelpers
  class TrajectoryCalculator
    DEFAULT_CELL_SIZE = TrajectoryService::DEFAULT_CELL_SIZE

    def self.calculate_future_position(position, speed, time_interval)
      future_x = position.position['x'] + speed[:speed_x] * time_interval
      future_y = position.position['y'] + speed[:speed_y] * time_interval
      grid_x = (future_x.to_f / DEFAULT_CELL_SIZE).round
      grid_y = (future_y.to_f / DEFAULT_CELL_SIZE).round

      {
        future_time: position.time + time_interval,
        future_x: future_x,
        future_y: future_y,
        grid_x: grid_x,
        grid_y: grid_y
      }
    end
  end
end
