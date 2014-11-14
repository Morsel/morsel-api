class CreateActivitySubscriptions < ActiveRecord::Migration
  def change
    create_table :activity_subscriptions do |t|
      t.integer :subscriber_id
      t.integer :subject_id
      t.string :subject_type
      t.integer :action, default: 0
      t.integer :reason, default: 0
      t.boolean :active, default: true
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :activity_subscriptions, [:subscriber_id]
    add_index :activity_subscriptions, [:subject_id, :subject_type]

    # TODO: Create subscribes for all existing activityables
    # subject.creator
    # subject.tagged_users if subject == morsel
    # subject.commenters if subject == item
    #
  end
end
