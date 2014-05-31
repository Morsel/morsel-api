class AddSettingsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :settings, :hstore, default: {}

    User.where(unsubscribed: true ).find_each do |user|
      user.update settings: { unsubscribed: true }
    end

    remove_column :users, :unsubscribed
  end

  def self.down
    add_column :users, :unsubscribed, :boolean, default: false

    User.where("settings -> 'unsubscribed' = 'true'").find_each do |user|
      user.update unsubscribed: true
    end

    remove_column :users, :settings
  end
end
