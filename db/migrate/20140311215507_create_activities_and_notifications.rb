class CreateActivitiesAndNotifications < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :subject_id
      t.string :subject_type
      t.integer :action_id
      t.string :action_type
      t.integer :creator_id
      t.integer :recipient_id
      t.integer :notification_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :activities, :subject_id
    add_index :activities, :creator_id
    add_index :activities, :recipient_id

    create_table :notifications do |t|
      t.integer :payload_id
      t.string :payload_type
      t.string :message
      t.integer :user_id
      t.datetime :marked_read_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :notifications, :user_id
  end
end


