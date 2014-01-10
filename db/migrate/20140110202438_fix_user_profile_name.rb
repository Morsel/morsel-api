class FixUserProfileName < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :profile, :photo
      t.rename :profile_content_type, :photo_content_type
      t.rename :profile_file_size, :photo_file_size
      t.rename :profile_updated_at, :photo_updated_at
    end
  end
end
