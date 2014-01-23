class UserPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # (Retina)
  version :_144x do
    process resize_to_fill: [144, 144]
  end

  version :_72x, from_version: :_144x do
    process resize_to_fill: [72, 72]
  end

  # Thumbnail (Retina)
  version :_80x do
    process resize_to_fill: [80, 80]
  end

  # Thumbnail
  version :_40x, from_version: :_80x do
    process resize_to_fill: [40, 40]
  end
end
