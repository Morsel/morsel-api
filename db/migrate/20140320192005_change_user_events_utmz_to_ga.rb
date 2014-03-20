class ChangeUserEventsUtmzToGa < ActiveRecord::Migration
  def change
    rename_column :user_events, :__utmz, :_ga
  end
end
