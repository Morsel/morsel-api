class ItemPhotoUploader < BasePhotoUploader
  include CarrierWave::MiniMagick

  # Web only
  version :_992x992 do
    process resize_to_fill: [992, 992]
  end

  version :_640x640 do
    process resize_to_fill: [640, 640]
  end

  version :_320x320 do
    process resize_to_fill: [320, 320]
  end

  version :_100x100 do
    process resize_to_fill: [100, 100]
  end

  version :_50x50 do
    process resize_to_fill: [50, 50]
  end
end
