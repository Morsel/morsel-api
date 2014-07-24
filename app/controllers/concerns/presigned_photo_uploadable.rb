module PresignedPhotoUploadable
  extend ActiveSupport::Concern

  def handle_presigned_upload(model, options = {})
    presigned_photo_uploadable_model = PresignedPhotoUploadableDecorator.new(model)
    service = presigned_photo_uploadable_model.prepare_presigned_upload
    if service.valid?
      if options[:serializer]
        custom_respond_with presigned_photo_uploadable_model, serializer: options[:serializer]
      else
        custom_respond_with presigned_photo_uploadable_model
      end
    else
      render_json_errors presigned_photo_uploadable_model.errors
    end
  end

  def handle_photo_key(photo_key, model, options = {})
    presigned_photo_uploadable_model = PresignedPhotoUploadableDecorator.new(model)
    service = presigned_photo_uploadable_model.handle_photo_key(photo_key)
    if service.valid?
      if options[:serializer]
        custom_respond_with presigned_photo_uploadable_model, serializer: options[:serializer]
      else
        custom_respond_with presigned_photo_uploadable_model
      end
    else
      render_json_errors presigned_photo_uploadable_model.errors
    end
  end
end
