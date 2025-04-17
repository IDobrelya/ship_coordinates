class CreateShips < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :ships, id: :uuid do |t|
      t.timestamps
    end
  end
end
