class AddSentAtToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :sent_at, :datetime
    Notification.update_all sent_at: DateTime.now # Mark everything as sent for now
  end

  def down
    remove_column :notifications, :sent_at
  end
end
