class CreateActivitySubscriptions < ActiveRecord::Migration
  def up
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

    Morsel.find_each do |morsel|
      morsel.send(:create_subscription_for_creator) unless morsel.creator.nil?
    end

    Item.find_each do |item|
      item.send(:create_subscription_for_creator) unless item.creator.nil?
    end

    MorselUserTag.find_each do |morsel_user_tag|
      morsel_user_tag.send(:subscribe_tagged_user_to_morsel_items)
    end

    Comment.find_each do |comment|
      comment.send(:subscribe_commenter_to_item)
    end
  end

  def down
    drop_table :activity_subscriptions
  end
end
