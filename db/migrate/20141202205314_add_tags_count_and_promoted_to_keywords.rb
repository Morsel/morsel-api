class AddTagsCountAndPromotedToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :promoted, :boolean, default: false
    add_index :keywords, :promoted

    add_column :keywords, :tags_count, :integer, null: false, default: 0
    Keyword.reset_column_information
    Keyword.find_each do |k|
      k.update_columns tags_count: Tag.where(keyword_id: k.id).count
    end
  end
end
