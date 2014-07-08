require 'carrierwave/processing/mime_types'

class BasePhotoUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay
  include CarrierWave::MimeTypes

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def store_dir
    PreparePresignedUpload.store_dir_for_model(model)
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if original_filename
      # TODO: Fix this so that duplicate files aren't created
      # if model && model.read_attribute(mounted_as).present?
      #   model.read_attribute(mounted_as)
      # else
        "#{secure_token}.#{file.extension}"
      # end
    end
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, PreparePresignedUpload.short_secure_token)
  end

  process :set_content_type
  process :save_content_type_and_size_in_model
  process :fix_exif_rotation
  process :strip

  def save_content_type_and_size_in_model
    model.photo_content_type = file.content_type if file.content_type
    model.photo_file_size = file.size
    model.photo_updated_at = Time.now
  end

  def fix_exif_rotation
    manipulate! do |img|
      img.auto_orient
      img = yield(img) if block_given?
      img
    end
  end

  def strip
    manipulate! do |img|
      img.strip
      img = yield(img) if block_given?
      img
    end
  end
end
