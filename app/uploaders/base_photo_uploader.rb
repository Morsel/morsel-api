require 'carrierwave/processing/mime_types'

class BasePhotoUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay
  include CarrierWave::MimeTypes
  include Piet::CarrierWaveExtension

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
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def secure_token
    PreparePresignedUpload.secure_token_for_model(model)
  end

  process :set_content_type
  process :save_content_type_and_size_in_model
  process :fix_exif_rotation
  process :strip
  process :optimize

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
