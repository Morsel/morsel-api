class MoveDraftAndPublishedToPosts < ActiveRecord::Migration
  def change
    remove_column :morsels, :draft
    remove_column :morsels, :published_at
    add_column :posts, :draft, :boolean, default: false, null: false
    add_column :posts, :published_at, :datetime
  end
end
