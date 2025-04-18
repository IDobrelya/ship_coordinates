point_x, point_y = @current_position.position.values_at('x', 'y')

json.time @current_position.time
json.x point_x
json.y point_y
json.speed @dispatcher_service.speed[:main_speed]
json.status @dispatcher_service.status

response.status = :created