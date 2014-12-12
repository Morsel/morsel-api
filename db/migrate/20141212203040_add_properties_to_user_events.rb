class AddPropertiesToUserEvents < ActiveRecord::Migration
  def change
    add_column :user_events, :properties, :hstore, default: {}
  end
end
