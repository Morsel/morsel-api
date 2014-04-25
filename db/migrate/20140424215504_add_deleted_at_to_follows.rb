class AddDeletedAtToFollows < ActiveRecord::Migration
  def change
    add_column :follows, :deleted_at, :datetime
  end
end
