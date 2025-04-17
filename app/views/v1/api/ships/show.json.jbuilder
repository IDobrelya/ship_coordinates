json.id @ship.id
json.positions @positions do |position|
  json.time position.time
  json.speed position.speed
  json.position position.position
end