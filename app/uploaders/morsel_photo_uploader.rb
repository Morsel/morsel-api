class MorselPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick
  def extension_white_list
    nil
  end
end
