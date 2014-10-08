module PhotoUploadable
  extend ActiveSupport::Concern

  included do
    attr_accessor :uploaded_from_remote
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
    self.uploaded_from_remote = remote_photo_url.present?
    return unless photo? && photo_changed?

    self.photo_content_type = photo.file.content_type
    self.photo_file_size = photo.file.size
    self.photo_updated_at = Time.now
  end
end
