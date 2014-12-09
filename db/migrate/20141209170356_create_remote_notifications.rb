class CreateRemoteNotifications < ActiveRecord::Migration
  def change
    create_table :remote_notifications do |t|
      t.references  :device, index: true
      t.references  :notification, index: true
      t.references  :user, index: true
      t.string      :activity_type
      t.string      :reason
      t.timestamps
    end
  end
end
