class AddPostIdAndSortOrderToMorsels < ActiveRecord::Migration
  def up
    add_column :morsels, :post_id, :integer
    add_column :morsels, :sort_order, :integer
    add_index :morsels, [:post_id]

    MorselPost.all.each do |mp|
      Morsel.where(id: mp.morsel_id).update_all(post_id: mp.post_id, sort_order: mp.sort_order)
    end

    drop_table :morsel_posts
  end

  def down
    create_table "morsel_posts", force: true do |t|
      t.integer "morsel_id"
      t.integer "post_id"
      t.integer "sort_order"
    end

    add_index "morsel_posts", ["morsel_id", "post_id"], name: "index_morsel_posts_on_morsel_id_and_post_id", using: :btree
  end
end
