class AddIdToMorselPost < ActiveRecord::Migration
  def change
    add_column :morsel_posts, :id, :primary_key
  end
end
