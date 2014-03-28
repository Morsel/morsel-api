class MorselPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # Web
  version :_992x992 do
    process resize_to_fill: [992, 992]
  end

  # iOS
  version :_640x640, from_version: :_992x992 do
    process resize_to_fill: [640, 640]
  end

  # Web
  version :_480x480, from_version: :_640x640 do
    process resize_to_fill: [480, 480]
  end

  # iOS
  version :_320x320, from_version: :_480x480 do
    process resize_to_fill: [320, 320]
  end

  # Web
  version :_240x240, from_version: :_320x320 do
    process resize_to_fill: [240, 240]
  end

  # iOS
  version :_100x100, from_version: :_240x240 do
    process resize_to_fill: [100, 100]
  end

  # Web
  version :_80x80, from_version: :_100x100 do
    process resize_to_fill: [80, 80]
  end

  version :_50x50, from_version: :_80x80 do
    process resize_to_fill: [50, 50]
  end
end
