class AddProfileContentTypeFileSizeAndUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_content_type, :string
    add_column :users, :profile_file_size, :string
    add_column :users, :profile_updated_at, :datetime
  end
end
