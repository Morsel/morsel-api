require 'carrierwave/processing/mime_types'

class BasePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def store_dir
    if Rails.env.production? || Rails.env.staging?
      "#{model.class.to_s.underscore}-photos/#{model.id}"
    elsif Rails.env.development?
      "#{Rails.root}/public/uploads_dev/#{model.class.to_s.underscore}-photos/#{model.id}"
    else
      "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}-photos/#{model.id}"
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
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
