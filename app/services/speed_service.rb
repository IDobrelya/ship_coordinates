class SpeedService
  attr_reader :speed

  DEFAULT_SPEED_VALUES = { main_speed: 0, speed_x: 0, speed_y: 0 }.freeze

  def initialize(current_position, previous_position = nil)
    @current_position = current_position
    @previous_position = previous_position
    @speed = DEFAULT_SPEED_VALUES
  end

  def current_speed
    return if @previous_position.blank?

    dx = current_x - previous_x
    dy = current_y - previous_y
    time_diff = current_time - previous_time
    speed_calculator(dx, dy, time_diff)
  end

  private

  def speed_calculator(dx, dy, time_diff)
    return DEFAULT_SPEED_VALUES if time_diff.zero?

    speed_x = (dx.to_f / time_diff).round
    speed_y = (dy.to_f / time_diff).round
    main_speed = (Math.sqrt((dx**2 + dy**2)) / time_diff).round
    @speed = { main_speed: main_speed, speed_x: speed_x, speed_y: speed_y }
  end

  def current_x = @current_position.position['x']
  def current_y = @current_position.position['y']
  def current_time = @current_position.time

  def previous_x = @previous_position.position['x']
  def previous_y = @previous_position.position['y']
  def previous_time = @previous_position.time
end