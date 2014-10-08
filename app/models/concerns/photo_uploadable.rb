module PhotoUploadable
  extend ActiveSupport::Concern

  included do
    before_save :update_photo_attributes
    process_in_background :photo, ProcessPhotoWorker
  end

  def photos
    return unless photo?

    photo.versions.keys.reduce({}) do |a, e|
      a[e] = photo_url(e)
      a
    end
  end

  private

  def update_photo_attributes
    return unless photo? && photo_changed?

    self.photo_content_type = photo.file.content_type
    self.photo_file_size = photo.file.size
    self.photo_updated_at = Time.now
  end
end
