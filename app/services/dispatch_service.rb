class DispatchService
  def initialize(current_position, previous_position = nil)
    @current_position = current_position
    @previous_position = previous_position
  end

  def current_speed
    return 0 if @previous_position.blank?

    speed_calculator
  end

  def get_status
    'green'
  end

  private

  def speed_calculator
    dx = current_x - previous_x
    dy = current_y - previous_y
    time_diff = current_time - previous_time
    return 0 if time_diff.zero?

    Math.sqrt((dx**2 + dy**2).to_f / time_diff).round
  end

  def current_x = @current_position.position['x']
  def current_y = @current_position.position['y']
  def current_time = @current_position.time

  def previous_x = @previous_position.position['x']
  def previous_y = @previous_position.position['y']
  def previous_time = @previous_position.time
end