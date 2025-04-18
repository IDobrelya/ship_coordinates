class DispatcherService
  attr_reader :speed, :status

  def initialize(
    ship_id,
    current_position,
    previous_position,
    speed_service_class: SpeedService,
    trajectory_class: TrajectoryService,
    status_service_class: StatusService,
    cache_service: nil
  )
    @ship_id = ship_id
    @current_position = current_position
    @previous_position = previous_position
    @speed_service_class = speed_service_class
    @trajectory_service_class = trajectory_class
    @status_service_class = status_service_class
    @cache_service = cache_service || TrajectoryCacheService.new(RedisService.new)
  end

  def call
    calculate_speed
    calculate_trajectory
    @status = determine_status
    cache_trajectory if @trajectory.present?
  end

  private

  def calculate_speed
    speed_svc = @speed_service_class.new(@current_position, @previous_position)
    speed_svc.current_speed
    @speed = speed_svc.speed
  end

  def calculate_trajectory
    trajectory_svc = @trajectory_service_class.new(@ship_id, @current_position, @speed)
    trajectory_svc.calculate_trajectory
    @trajectory = trajectory_svc.trajectory
  end

  def determine_status
    status_svc = @status_service_class.new(@ship_id, @trajectory, @speed)
    status_svc.recognize_status
    status_svc.status
  end

  def cache_trajectory
    @cache_service.set_trajectory(@trajectory)
  end
end