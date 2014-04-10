class RenameMorselsToItemsAndPostsToMorsels < ActiveRecord::Migration
  def change
    rename_index :comments, 'index_comments_on_user_id_and_morsel_id', 'index_comments_on_user_id_and_item_id'
    rename_column :comments, :morsel_id, :item_id # maybe make this poly?

    rename_index :likes, 'index_likes_on_user_id_and_morsel_id', 'index_likes_on_user_id_and_item_id'
    rename_column :likes, :morsel_id, :item_id # maybe make this poly?

    rename_column :posts, :primary_morsel_id, :primary_item_id

    rename_index :morsels, 'index_morsels_on_creator_id', 'index_items_on_creator_id'
    rename_index :morsels, 'index_morsels_on_post_id', 'index_items_on_post_id'
    rename_column :morsels, :post_id, :morsel_id
    rename_table :morsels, :items


    rename_index :posts, 'index_posts_on_cached_slug', 'index_morsels_on_cached_slug'
    rename_index :posts, 'index_posts_on_creator_id', 'index_morsels_on_creator_id'
    rename_table :posts, :morsels
  end
end
