class AddDeletedAtToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :deleted_at, :datetime
    add_index :authentications, :deleted_at
  end
end
