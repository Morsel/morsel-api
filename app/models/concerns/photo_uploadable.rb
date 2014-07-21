module PhotoUploadable
  extend ActiveSupport::Concern

  included do
    before_save :update_photo_attributes
  end

  def photos
    photo.versions.keys.reduce({}) { |a, e| a[e] = photo_url(e); a } if photo?
  end

  private

  def update_photo_attributes
    if photo? && photo_changed?
      self.photo_content_type = photo.file.content_type
      self.photo_file_size = photo.file.size
      self.photo_updated_at = Time.now
    end
  end
end
