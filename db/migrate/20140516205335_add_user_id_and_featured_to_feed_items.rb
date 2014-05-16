class AddUserIdAndFeaturedToFeedItems < ActiveRecord::Migration
  def up
    add_column :feed_items, :user_id, :integer
    add_index :feed_items, :user_id
    add_column :feed_items, :featured, :boolean, default: false
    add_index :feed_items, :featured

    FeedItem.find_each(conditions: "subject_type = 'Morsel'") do |feed_item|
      feed_item.update(user_id: feed_item.subject.user_id)
    end
  end

  def down
    remove_index :feed_items, column: :user_id
    remove_column :feed_items, :user_id
    remove_index :feed_items, column: :featured
    remove_column :feed_items, :featured
  end
end
