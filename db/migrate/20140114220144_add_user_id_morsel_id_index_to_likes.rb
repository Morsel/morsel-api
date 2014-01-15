class AddUserIdMorselIdIndexToLikes < ActiveRecord::Migration
  def change
    add_index :likes, [:user_id, :morsel_id]
  end
end
