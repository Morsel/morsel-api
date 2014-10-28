class AddNoteToCollectionMorsels < ActiveRecord::Migration
  def change
    add_column :collection_morsels, :note, :text
  end
end
