class AddCachedPrimaryItemPhotosToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :cached_primary_item_photos, :hstore
  end
end
