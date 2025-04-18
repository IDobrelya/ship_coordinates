json.id @ship.id
json.positions @positions do |position|
  json.time position.time
  json.speed position.speed
  json.position position.position
end

json.pagination do
  json.current_page @pagy.page
  json.next_page @pagy.next
  json.total_pages @pagy.pages
end
