class RemoveRecipientIdAndNotificationIdFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :notification_id, :integer
    remove_column :activities, :recipient_id, :integer
  end
end
