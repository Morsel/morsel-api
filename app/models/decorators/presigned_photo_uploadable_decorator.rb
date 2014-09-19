class PresignedPhotoUploadableDecorator < SimpleDelegator
  attr_reader :presigned_upload

  def handle_photo_key(photo_key)
    HandlePhotoKey.call(
      model: __getobj__,
      photo_key: photo_key
    )
  end

  def prepare_presigned_upload
    service = PreparePresignedUpload.call(model: __getobj__)
    @presigned_upload = service.response
    service
  end
end
