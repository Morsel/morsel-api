# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`like_count`**          | `integer`          | `default(0), not null`
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
#

class Morsel < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :creator, foreign_key: 'creator_id', class_name: 'User'
  has_and_belongs_to_many :posts
  has_many :liking_users, through: :likes, source: :user
  has_many :likes

  include PhotoUploadable

  mount_uploader :photo, MorselPhotoUploader

  before_save :update_photo_attributes

  validate :description_or_photo_present?

  private

  def description_or_photo_present?
    errors.add(:description_or_photo, 'is required.') if description.blank? && photo.blank?
  end
end
