class CreatePositions < ActiveRecord::Migration[7.1]
  def change
    create_table :positions do |t|
      t.integer :time, null: false
      t.integer :speed, null: false
      t.string :status
      t.jsonb :position, null: false
      t.references :ship, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
