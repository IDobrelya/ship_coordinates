class AddIndexesToPositionsTable < ActiveRecord::Migration[7.1]
  def change
    add_index :positions, :time, order: { time: :desc }, name: 'index_positions_on_date_desc'
    add_index :positions, [:ship_id, :time], order: { time: :desc }, name: 'index_positions_on_ship_id_and_date_desc'
  end
end
