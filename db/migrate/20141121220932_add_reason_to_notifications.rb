class AddReasonToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :reason, :string, null: true
    change_column :notifications, :message, :text
  end
end
