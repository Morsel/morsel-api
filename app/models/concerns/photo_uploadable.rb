module PhotoUploadable
  extend ActiveSupport::Concern

  included do
    before_save :update_photo_attributes
  end

  private

    def update_photo_attributes
      if photo.present? && photo_changed?
        self.photo_content_type = photo.file.content_type
        self.photo_file_size = photo.file.size
        self.photo_updated_at = Time.now
      end
    end
end
