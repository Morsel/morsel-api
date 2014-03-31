class ChangeGaToUtmzInUserEvents < ActiveRecord::Migration
  def up
    change_column :user_events, :_ga, :text
    rename_column :user_events, :_ga, :__utmz
  end

  def down
    rename_column :user_events, :__utmz, :_ga
    change_column :user_events, :_ga, :hstore
  end
end
