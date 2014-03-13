class MorselPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # iOS
  version :_640x640 do
    process resize_to_fill: [640, 640]
  end

  # iOS
  version :_320x320, from_version: :_640x640 do
    process resize_to_fill: [320, 320]
  end

  # iOS
  version :_100x100, from_version: :_320x320 do
    process resize_to_fill: [100, 100]
  end

  # iOS
  version :_50x50, from_version: :_100x100 do
    process resize_to_fill: [50, 50]
  end
end
