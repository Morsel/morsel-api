class AddNotificationSettingsToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :notification_settings, :hstore, default: {}
  end
end
