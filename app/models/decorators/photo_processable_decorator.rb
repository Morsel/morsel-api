class PhotoProcessableDecorator < SimpleDelegator
  attr_reader :presigned_upload

  def after_processing_success
    if respond_to?(:photo_processing)
      # HACK: Fix for remote_photo_url's not unsetting `photo_processing`
      update(photo_processing: nil) if photo_processing? && uploaded_from_remote
    end
  end

  def after_processing_failure
  end
end
