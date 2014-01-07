class RenameUserToCreatorInMorsels < ActiveRecord::Migration
  def change
    rename_index :morsels, 'index_morsels_on_user_id', 'index_morsels_on_creator_id'
    rename_column :morsels, :user_id, :creator_id
  end
end
