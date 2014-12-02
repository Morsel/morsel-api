class AddTagsCountAndPromotedToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :promoted, :boolean, default: false
    add_index :keywords, :promoted

    add_column :keywords, :tags_count, :integer, null: false, default: 0
  end
end
