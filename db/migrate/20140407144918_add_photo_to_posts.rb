class AddPhotoToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :photo, :string
    add_column :posts, :photo_content_type, :string
    add_column :posts, :photo_file_size, :string
    add_column :posts, :photo_updated_at, :datetime
  end
end
