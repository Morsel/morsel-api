class AddDeletedAtToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :deleted_at, :datetime
  end
end
