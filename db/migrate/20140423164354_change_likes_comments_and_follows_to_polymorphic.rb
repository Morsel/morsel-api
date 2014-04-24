class ChangeLikesCommentsAndFollowsToPolymorphic < ActiveRecord::Migration
  def up
    # Likes
    rename_column :likes, :user_id, :liker_id
    rename_column :likes, :item_id, :likeable_id
    add_column :likes, :likeable_type, :string
    # rename_index :likes, 'index_likes_on_user_id_and_item_id', 'index_likes_on_liker_id_and_likeable_id'

    Like.find_each do |l|
      l.update likeable_type: 'Item'
    end


    # Comments
    rename_column :comments, :user_id, :commenter_id
    rename_column :comments, :item_id, :commentable_id
    add_column :comments, :commentable_type, :string
    # rename_index :comments, 'index_comments_on_user_id_and_item_id', 'index_comments_on_commenter_id_and_commentable_id'

    Comment.find_each do |c|
      c.update commentable_type: 'Item'
    end


    # Follows
    rename_column :follows, :followed_id, :followable_id
    add_column :follows, :followable_type, :string
    add_index :follows, [:followable_id, :follower_id]
  end

  def down
    # Follows
    drop_table :follows


    # Comments
    remove_column :comments, :commentable_type
    rename_column :comments, :commenter_id, :user_id
    rename_column :comments, :commentable_id, :item_id
    # rename_index :comments, 'index_comments_on_commenter_id_and_commentable_id', 'index_comments_on_user_id_and_item_id'


    # Likes
    remove_column :likes, :likeable_type
    rename_column :likes, :liker_id, :user_id
    rename_column :likes, :likeable_id, :item_id
    # rename_index :likes, 'index_likes_on_liker_id_and_likeable_id', 'index_likes_on_user_id_and_item_id'
  end
end
