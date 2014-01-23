class MorselPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # (Retina)
  version :_640x428 do
    process resize_to_fill: [640, 428]
  end

  version :_320x214, from_version: :_640x428 do
    process resize_to_fill: [320, 214]
  end

  # Thumbnail (Retina)
  version :_208x do
    process resize_to_fill: [208, 208]
  end

  # Thumbnail
  version :_104x, from_version: :_208x do
    process resize_to_fill: [104, 104]
  end
end
