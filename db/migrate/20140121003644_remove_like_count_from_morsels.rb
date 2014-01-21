class RemoveLikeCountFromMorsels < ActiveRecord::Migration
  def change
    remove_column :morsels, :like_count
  end
end
