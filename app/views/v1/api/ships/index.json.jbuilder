json.ships @ships do |ship|
  json.id ship.id
  json.last_time ship.last_time
  json.last_status ship.last_status
  json.last_speed ship.last_speed
  json.last_position ship.last_position
end