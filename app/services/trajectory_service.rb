class TrajectoryService
  attr_reader :trajectory

  DEFAULT_CELL_SIZE = 1_000
  DEFAULT_TRAJECTORY_STEPS = 60

  def initialize(ship_id, position, speed, start_time = current_time)
    @ship_id = ship_id
    @positions = position
    @start_time = start_time
    @speed = speed
    @trajectory = Hash.new { |h, k| h[k] = [] }
  end

  def calculate_trajectory
    return unless ship_moving?

    (1..DEFAULT_TRAJECTORY_STEPS).each do |t|
      future_time = @start_time + t
      future_x = @positions.position['x'] + @speed[:speed_x] * t
      future_y = @positions.position['y'] + @speed[:speed_y] * t

      grid_x = future_x.to_f / DEFAULT_CELL_SIZE
      grid_y = future_y.to_f / DEFAULT_CELL_SIZE

      key = "future:grid:#{future_time}:#{grid_x.round}:#{grid_y.round}"
      @trajectory[key] << { ship_id: @ship_id, x: future_x.round, y: future_y.round, version: @start_time.to_s }
    end
  end

  private

  def ship_moving?
    @speed[:main_speed].present? && @speed[:main_speed] > 0
  end

  def current_time
    Time.now.to_i
  end
end