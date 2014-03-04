class CreateUserEvents < ActiveRecord::Migration
  def change
    create_table :user_events do |t|
      t.integer :user_id
      t.string :name
      t.string :client_version
      t.string :client_device
      t.hstore :__utmz
      t.timestamps
    end
    add_index :user_events, :user_id
    add_index :user_events, :name
  end
end
