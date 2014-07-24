class PresignedPhotoUploadableDecorator < SimpleDelegator
  def handle_photo_key(photo_key)
    HandlePhotoKey.call(
      model: self.__getobj__,
      photo_key: photo_key
    )
  end

  def prepare_presigned_upload
    service = PreparePresignedUpload.call(model: self.__getobj__)
    @presigned_upload = service.response
    service
  end

  def presigned_upload
    @presigned_upload
  end
end
