class AddCachedSlugToCollections < ActiveRecord::Migration
  
  def self.up
    add_column :collections, :cached_slug, :string
    add_index  :collections, :cached_slug
  end

  def self.down
    remove_column :collections, :cached_slug
  end
  
end
