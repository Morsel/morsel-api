require 'carrierwave/processing/mime_types'

class UserProfileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def store_dir
    "profile-images/#{model.class.to_s.underscore}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    @name ||= "#{timestamp}-#{super}" if original_filename.present? && super.present?
  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) || model.instance_variable_set(var, Time.now.to_i)
  end

  process :set_content_type
  process :save_content_type_and_size_in_model

  def save_content_type_and_size_in_model
    model.profile_content_type = file.content_type if file.content_type
    model.profile_file_size = file.size
    model.profile_updated_at = Time.now
  end
end
