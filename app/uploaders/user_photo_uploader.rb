class UserPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # (Retina)
  version :_144x144 do
    process resize_to_fill: [144, 144]
  end

  version :_72x72, from_version: :_144x144 do
    process resize_to_fill: [72, 72]
  end

  # Thumbnail (Retina), Admin
  version :_80x80 do
    process resize_to_fill: [80, 80]
  end

  # Thumbnail
  version :_40x40, from_version: :_80x80 do
    process resize_to_fill: [40, 40]
  end
end
