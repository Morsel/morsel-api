class AddCreatorIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :creator_id, :integer
    add_index :posts, :creator_id
  end
end
