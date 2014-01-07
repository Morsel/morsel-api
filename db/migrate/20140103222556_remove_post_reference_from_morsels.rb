class RemovePostReferenceFromMorsels < ActiveRecord::Migration
  def change
    remove_index :morsels, column: :post_id
    remove_column :morsels, :post_id
  end
end
