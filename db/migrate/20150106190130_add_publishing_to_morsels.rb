class AddPublishingToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :publishing, :boolean, default: false
  end
end
