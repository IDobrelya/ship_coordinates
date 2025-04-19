class StatusService
  attr_reader :status

  STATUSES = { safe: 'green', warn: 'yellow', danger: 'red' }.freeze
  CELL_SAFE_DISTANCE = 0

  def initialize(ship_id, trajectory, speed, cache_service = RedisService.new )
    @ship_id = ship_id
    @trajectory = trajectory
    @speed = speed
    @cache_service = TrajectoryCacheService.new(cache_service)
    @status = STATUSES[:safe]
  end

  def recognize_status
    cache_current_version
    return unless ship_moving?

    check_collisions
  end

  private

  def ship_moving?
    @speed[:main_speed].present? && @speed[:main_speed] > 0
  end

  def check_collisions
    @trajectory.each do |trajectory_key, trajectory_value|
      ship_trajectories = @cache_service.get_trajectory(trajectory_key)
      current_trajectory = trajectory_value.first
      @status = STATUSES[:danger] if position_occupied?(current_trajectory[:x], current_trajectory[:y])
      return if @status == STATUSES[:danger]

      detect_collisions(ship_trajectories, trajectory_value.first)
    end
  end

  def detect_collisions(trajectories, own_trajectory)
    trajectories.each do |ship_json_data|
      ship_data = JSON.parse(ship_json_data, symbolize_names: true)
      next unless trajectory_data_valid?(ship_data)

      distance = get_distance(own_trajectory, ship_data)
      update_status_based_on(distance)
      return if status == STATUSES[:danger]
    end
  end

  def position_occupied?(point_x, point_y)
    position_key = "positions:#{point_x}:#{point_y}"
    occupied_by_ship = @cache_service.get_position(position_key)
    occupied_by_ship.present?
  end

  def update_status_based_on(distance)
    @status =
      if distance < CELL_SAFE_DISTANCE
        STATUSES[:danger]
      elsif distance == CELL_SAFE_DISTANCE
        STATUSES[:warn]
      else
        @status
      end
  end

  def trajectory_data_valid?(trajectory_data)
    cache_key = "ship:#{trajectory_data[:ship_id]}"
    cache_version = @cache_service.version(cache_key)
    cache_version.present? && cache_version != trajectory_data['version']
  end

  def get_distance(own_trajectory, other_trajectory)
    own_points = { x: own_trajectory[:x], y: own_trajectory[:y] }
    other_ship_points = { x: other_trajectory[:x], y: other_trajectory[:y] }
    calculate_distance(own_points, other_ship_points)
  end

  def calculate_distance(point_a, point_b)
    dx = (point_a[:x] - point_b[:x]).abs
    dy = (point_a[:y] - point_b[:y]).abs
    [dx, dy].max - 1
  end

  def save_trajectory(trajectory)
    @cache_service.batch_set_insert(trajectory)
  end

  def cache_current_version
    key = "ship:#{@ship_id}"
    @cache_service.save_version(key, current_time)
  end

  def current_time
    Time.now.to_i
  end
end