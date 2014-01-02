class AddPhotoContentTypeFileSizeUpdatedAtToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :photo, :string
    add_column :morsels, :photo_content_type, :string
    add_column :morsels, :photo_file_size, :string
    add_column :morsels, :photo_updated_at, :datetime
  end
end
