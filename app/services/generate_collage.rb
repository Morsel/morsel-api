class GenerateCollage
  include Service

  COLLAGE_WIDTH = 840
  COLLAGE_HEIGHT = 420
  COLLAGE_LOCAL_PATH  =  '' #Rails.env.development? ? "#{Rails.root}/public" : ''
  COLLAGE_PADDING = 4
  COLLAGE_HALF_PADDING = 2
  COLLAGE_COVER_WIDTH = 630
  COLLAGE_CELL_WIDTH = 210

  attribute :morsel, Morsel

  validates :morsel, presence: true

  validate :cover_item?
  validate :items?

  def call
    return unless collage
    collage.format 'jpg'
    collage
  end

  private

  def cover_item?
    errors.add(:morsel, 'should have a cover item set') if morsel.primary_item.nil?
  end

  def items?
    errors.add(:morsel, 'should have at least 1 item') unless morsel.item_count > 0
  end

  def collage
    @collage ||= begin
      if item_count > 2
        composite_three_item_collage.mrsl_watermark
      elsif item_count > 1
        composite_two_item_collage.mrsl_watermark
      else
        composite_one_item_collage.mrsl_watermark
      end
    end
  end

  def cover_item
    @cover_item ||= morsel.primary_item
  end

  def additional_items
    @additional_items ||= morsel.items.where(Item.arel_table[:photo].not_eq(nil).and(Item.arel_table[:id].not_eq(morsel.primary_item_id))).limit(2)
  end

  def item_count
    @item_count ||= (cover_item ? 1 : 0) + additional_items.count
  end

  def image_for_item(item, photo_version = :_320x320)
    MiniMagick::Image.open(COLLAGE_LOCAL_PATH + item.photo_url(photo_version))
  end

  def canvas
    @canvas ||= begin
      tmp = Tempfile.new %w(mini_magick_collage_ .png)
      if item_count > 1
        `convert -size #{COLLAGE_WIDTH}x#{COLLAGE_HEIGHT} xc:white #{tmp.path}`
      else
        `convert -size #{COLLAGE_HEIGHT}x#{COLLAGE_HEIGHT} xc:white #{tmp.path}`
      end
      MiniMagick::Image.new(tmp.path, tmp)
    end
  end

  def composite_one_item_collage
    canvas.composite(image_for_item(cover_item, :_640x640)) do |cover|
      cover.compose 'Over'
      cover.gravity 'Center'
      cover.geometry "#{COLLAGE_HEIGHT}x#{COLLAGE_HEIGHT}+0+0"
    end
  end

  def composite_two_item_collage
    canvas.composite(image_for_item(cover_item, :_640x640)) do |cover|
      cover.compose 'Over'
      cover.gravity 'West'
      cover.geometry "#{COLLAGE_HEIGHT}x#{COLLAGE_HEIGHT}-#{COLLAGE_HALF_PADDING}+0"
    end.composite(image_for_item(additional_items.first, :_640x640)) do |first_item|
      first_item.compose 'Over'
      first_item.gravity 'East'
      first_item.geometry "#{COLLAGE_HEIGHT}x#{COLLAGE_HEIGHT}-#{COLLAGE_HALF_PADDING}+0"
    end
  end

  def composite_three_item_collage
    canvas.composite(image_for_item(cover_item, :_640x640)) do |cover|
      cover.compose 'Over'
      cover.gravity 'West'
      cover.geometry "#{COLLAGE_COVER_WIDTH - COLLAGE_HALF_PADDING}x#{COLLAGE_COVER_WIDTH - COLLAGE_HALF_PADDING}+0+0"
    end.composite(image_for_item(additional_items.first)) do |first_item|
      first_item.compose 'Over'
      first_item.gravity 'NorthEast'
      first_item.geometry "#{COLLAGE_CELL_WIDTH - COLLAGE_HALF_PADDING}x#{COLLAGE_CELL_WIDTH - COLLAGE_HALF_PADDING}+0+0"
    end.composite(image_for_item(additional_items.second)) do |second_item|
      second_item.compose 'Over'
      second_item.gravity 'SouthEast'
      second_item.geometry "#{COLLAGE_CELL_WIDTH - COLLAGE_HALF_PADDING}x#{COLLAGE_CELL_WIDTH - COLLAGE_HALF_PADDING}+0+0"
    end
  end
end

module MiniMagick
  class Image
    COLLAGE_WATERMARK_IMAGE = Rails.root.join('app', 'assets', 'images', 'watermark.png')

    def mrsl_watermark
      composite(watermark_image) do |watermark|
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
