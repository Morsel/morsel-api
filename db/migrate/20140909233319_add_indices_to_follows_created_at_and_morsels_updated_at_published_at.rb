class AddIndicesToFollowsCreatedAtAndMorselsUpdatedAtPublishedAt < ActiveRecord::Migration
  def change
    add_index :follows, :created_at
    add_index :morsels, [:updated_at, :published_at]
  end
end
