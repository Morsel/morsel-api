class GenerateCollage
  include Service

  COLLAGE_WIDTH=840
  COLLAGE_HEIGHT=420
  COLLAGE_LOCAL_PATH = Rails.env.development? ? "#{Rails.root}/public" : ''
  COLLAGE_PADDING=4
  COLLAGE_COVER_WIDTH=628
  COLLAGE_CELL_WIDTH=208

  attribute :morsel, Morsel

  validates :morsel, presence: true

  validate :has_items?

  def call
    # Add cover
    output = canvas.composite(image_for_item(cover_item)) do |cover|
      cover.compose 'Over'
      cover.gravity 'NorthWest'
      cover.geometry "#{COLLAGE_COVER_WIDTH}x#{COLLAGE_COVER_WIDTH}+0-104"
    end.composite(image_for_item(additional_items.first)) do |first_item|
      first_item.compose 'Over'
      first_item.gravity 'NorthEast'
      first_item.geometry "#{COLLAGE_CELL_WIDTH}x#{COLLAGE_CELL_WIDTH}+0+0"
    end.composite(image_for_item(additional_items.second)) do |second_item|
      second_item.compose 'Over'
      second_item.gravity 'SouthEast'
      second_item.geometry "#{COLLAGE_CELL_WIDTH}x#{COLLAGE_CELL_WIDTH}+0+0"
    end.mrsl_watermark

    output.format 'jpg'
    output
  end

  private

  def has_items?
    errors.add(:morsel, 'has no items') unless morsel.item_count > 0
  end

  def cover_item
    @cover_item ||= morsel.primary_item
  end

  def additional_items
    @additional_items ||= morsel.items.where(Item.arel_table[:photo].not_eq(nil).and(Item.arel_table[:id].not_eq(morsel.primary_item_id))).limit(2)
  end

  def image_for_item(item, photo_version = :_320x320)
    MiniMagick::Image.open(COLLAGE_LOCAL_PATH+item.photo_url(photo_version))
  end

  def canvas
    @canvas ||= begin
      tmp = Tempfile.new(%W[mini_magick_collage_ .png])
      `convert -size #{COLLAGE_WIDTH}x#{COLLAGE_HEIGHT} xc:white #{tmp.path}`
      MiniMagick::Image.new(tmp.path, tmp)
    end
  end
end

module MiniMagick
  class Image
    COLLAGE_WATERMARK_IMAGE = Rails.root.join('app', 'assets', 'images', 'watermark.png')

    def mrsl_watermark
      self.composite(watermark_image) do |watermark|
        watermark.compose 'Over'
        watermark.gravity 'SouthWest'
        watermark.geometry "140x60+#{GenerateCollage::COLLAGE_PADDING * 3}+#{GenerateCollage::COLLAGE_PADDING * 3}"
      end
    end

    private

    def watermark_image
      @watermark_image ||= MiniMagick::Image.open(COLLAGE_WATERMARK_IMAGE)
    end
  end
end
