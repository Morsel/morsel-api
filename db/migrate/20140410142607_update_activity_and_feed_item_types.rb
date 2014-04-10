class UpdateActivityAndFeedItemTypes < ActiveRecord::Migration
  def up
    Activity.where(subject_type: 'Morsel').update_all(subject_type: 'Item')
    FeedItem.where(subject_type: 'Post').update_all(subject_type: 'Morsel')

    Role.where(resource_type: 'Morsel').update_all(resource_type: 'Item')
    Role.where(resource_type: 'Post').update_all(resource_type: 'Morsel')
  end

  def down
    Role.where(resource_type: 'Morsel').update_all(resource_type: 'Post')
    Role.where(resource_type: 'Item').update_all(resource_type: 'Morsel')

    FeedItem.update_all(subject_type: 'Post')
    Activity.update_all(subject_type: 'Morsel')
  end
end
