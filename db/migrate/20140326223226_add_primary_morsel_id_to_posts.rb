class AddPrimaryMorselIdToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :primary_morsel_id, :integer
    Post.find_each do |post|
      last_morsel = post.morsels.last
      post.update(primary_morsel_id: last_morsel.id) if last_morsel
    end
  end

  def down
    remove_column :posts, :primary_morsel_id
  end
end
