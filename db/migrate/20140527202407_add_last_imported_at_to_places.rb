class AddLastImportedAtToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :last_imported_at, :datetime
  end
end
