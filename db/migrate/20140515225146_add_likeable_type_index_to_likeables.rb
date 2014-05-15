class AddLikeableTypeIndexToLikeables < ActiveRecord::Migration
  def change
    add_index :comments, [:commentable_type]
    add_index :follows, [:followable_type]
    add_index :likes, [:likeable_type]
    add_index :tags, [:taggable_type]
    add_index :activities, [:subject_type, :action_type]
    add_index :notifications, [:payload_type]
  end
end
