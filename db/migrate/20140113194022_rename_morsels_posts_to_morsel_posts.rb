class RenameMorselsPostsToMorselPosts < ActiveRecord::Migration
  def change
    rename_table :morsels_posts, :morsel_posts
    add_column :morsel_posts, :sort_order, :integer
  end
end
