class AddPublishedAtToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :published_at, :datetime
  end
end
