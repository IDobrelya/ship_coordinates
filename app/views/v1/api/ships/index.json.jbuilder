json.ships @positions do |ship|
  json.id ship.ship_id
  json.last_time ship.last_time
  json.last_status ship.last_status
  json.last_speed ship.last_speed
  json.last_position ship.last_position
end

json.pagination do
  json.current_page @pagy.page
  json.next_page @pagy.next
end
