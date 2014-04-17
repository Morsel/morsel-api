module MiniMagick
  class Image
    def composite_title(title, options = {})
      max_width = options[:max_width] || 760
      max_height = options[:max_height] || 160
      x = options[:x] || 20
      y = options[:y] || 20

      tmp_title_outer = Tempfile.new(%W[mini_magick_collage_title_outer_ .png])
      tmp_title_inner = Tempfile.new(%W[mini_magick_collage_title_inner_ .png])

      `convert -font #{MorselCollageGeneratorDecorator::ROBOTO_SLAB_BOLD} \
        -size #{max_width}x#{max_height} \
        -background none \
        -fill white \
        -strokewidth 6 \
        -stroke black \
        label:"#{title}" \
        #{tmp_title_outer.path}`

      `convert -font #{MorselCollageGeneratorDecorator::ROBOTO_SLAB_BOLD} \
        -size #{max_width}x#{max_height} \
        -background none \
        -fill white \
        -strokewidth 6 \
        -stroke none \
        label:"#{title}" \
        #{tmp_title_inner.path}`

      title_outer_image = MiniMagick::Image.new(tmp_title_outer.path, tmp_title_outer)
      title_inner_image = MiniMagick::Image.new(tmp_title_inner.path, tmp_title_inner)

      self.composite(title_outer_image) do |c|
        c.compose 'Over'
        c.gravity 'NorthWest'
        c.geometry "+#{x}+#{y}"
      end.composite(title_inner_image) do |c|
        c.compose 'Over'
        c.gravity 'NorthWest'
        c.geometry "+#{x}+#{y}"
      end
    end

    def add_creator_information(creator)
      creator_photo_url = creator.photo_url(:_144x144) ? MorselCollageGeneratorDecorator::COLLAGE_LOCAL_PATH+creator.photo_url(:_144x144) : MorselCollageGeneratorDecorator::COLLAGE_PLACEHOLDER_IMAGE
      image = self.composite(MiniMagick::Image.open(creator_photo_url)) do |c|
        c.compose 'Over'
        c.gravity 'SouthWest'
        c.geometry '100x100+20+20'
      end

      creator_name_x = 140
      creator_name_y = 68
      creator_url_y = 38

      image.combine_options do |c|
        c.fill "white"
        c.strokewidth 2
        c.gravity 'SouthWest'
        c.font MorselCollageGeneratorDecorator::ROBOTO_SLAB

        c.size '600x'
        c.background 'red'
        c.stroke 'black'
        c.pointsize 30
        c.draw "text #{creator_name_x}, #{creator_name_y} '#{creator.full_name}'"
        c.stroke 'none'
        c.draw "text #{creator_name_x}, #{creator_name_y} '#{creator.full_name}'"

        c.font MorselCollageGeneratorDecorator::ROBOTO
        c.size '600x'
        c.background 'blue'
        c.stroke 'black'
        c.pointsize 20
        c.draw "text #{creator_name_x}, #{creator_url_y} 'www.eatmorsel.com/#{creator.username}'"
        c.stroke 'none'
        c.draw "text #{creator_name_x}, #{creator_url_y} 'www.eatmorsel.com/#{creator.username}'"
      end

      image
    end
  end
end

class MorselCollageGeneratorDecorator < SimpleDelegator
  # TODO:
  #   Tests. Use somethiing like wraith to compare images in a spec to make sure result is correct: https://github.com/BBC-News/wraith/blob/master/spec/wraith_spec.rb http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  #   Cleanup, decouple, and DRY.

  COLLAGE_PADDING = 8
  COLLAGE_SINGLE_CELL_SIZE = 190
  COLLAGE_DOUBLE_CELL_SIZE = (COLLAGE_SINGLE_CELL_SIZE * 2) + COLLAGE_PADDING
  COLLAGE_TRIPLE_CELL_SIZE = (COLLAGE_SINGLE_CELL_SIZE * 3) + COLLAGE_PADDING + COLLAGE_PADDING
  ROBOTO = Rails.root.join('app', 'assets', 'fonts', 'Roboto-Regular.ttf')
  ROBOTO_SLAB = Rails.root.join('app', 'assets', 'fonts', 'RobotoSlab-Regular.ttf')
  ROBOTO_SLAB_BOLD = Rails.root.join('app', 'assets', 'fonts', 'RobotoSlab-Bold.ttf')
  COLLAGE_PLACEHOLDER_IMAGE = Rails.root.join('app', 'assets', 'images', 'm_144x144.png')
  COLLAGE_LOCAL_PATH = Rails.env.development? ? "#{Rails.root}/public" : ''
  COLLAGE_DEFAULT_GRAVITY = 'NorthWest'

  def generate
    item_count = valid_items().count
    if item_count == 1
      self.photo = generate_one_item_collage
      save!
    elsif item_count == 2
      self.photo = generate_two_item_collage
      save!
    elsif item_count == 3
      self.photo = generate_three_item_collage
      save!
    elsif item_count == 4
      self.photo = generate_four_item_collage
      save!
    elsif item_count == 5
      self.photo = generate_five_item_collage
      save!
    elsif item_count == 6
      self.photo = generate_six_item_collage
      save!
    elsif item_count >= 7
      self.photo = generate_seven_item_collage
      save!
    else
      puts "Invalid Morsel passed: #{id} or no template exists for Morsel with #{item_count} Items"
    end
  end

  private

  def valid_items
    valid_items = []

    primary_item = self.primary_item
    valid_items.push(primary_item) if primary_item

    self.items.each do |m|
      valid_items.push(m) if m.photo_url && m != primary_item
    end

    valid_items
  end

  def blurred_image(image_path, options = {})
    width = options[:width] || 800
    height = options[:height] || 800
    max_width = options[:max_width] || 800
    max_height = options[:max_height] || 800

    tmp = Tempfile.new(%W[mini_magick_collage_ .png])

    # -modulate brightness[,saturation,hue]
    # Vary the brightness, saturation, and hue of an image.
    # The arguments are given as a percentages of variation. A value of 100 means no change, and any missing values are taken to mean 100.
    # The brightness is a multiplier of the overall brightness of the image, so 0 means pure black, 50 is half as bright, 200 is twice as bright. To invert its meaning -negate the image before and after.
    # The saturation controls the amount of color in an image. For example, 0 produce a grayscale image, while a large value such as 200 produce a very colorful, 'cartoonish' color.
    `convert '#{image_path}' -gaussian-blur 20 -modulate 70,40 -resize #{max_width}x#{max_height} -extent #{width}x#{height} #{tmp.path}`
    MiniMagick::Image.new(tmp.path, tmp)
  end

  # A-title- AA
  # AA AA AA AA
  # AA AA AA AA
  # AA AA AA AA
  # AA AA AA AA
  # creator- AA
  def generate_one_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 600, width: 600, max_height: 600, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_TRIPLE_CELL_SIZE}x#{COLLAGE_TRIPLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: 560}).add_creator_information(self.creator)

    result.format 'png'
    result
  end

  # AA AA AA BB
  # AA AA AA BB
  # A-titl-A --
  # AA AA AA --
  # AA AA AA --
  # creator- --
  def generate_two_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_TRIPLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_TRIPLE_CELL_SIZE}x#{COLLAGE_TRIPLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: 560}).add_creator_information(self.creator)

    result.format 'png'
    result
  end

  # AA AA AA BB
  # AA AA AA BB
  # A-titl-A CC
  # AA AA AA CC
  # AA AA AA --
  # creator- --
  def generate_three_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_TRIPLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_TRIPLE_CELL_SIZE}x#{COLLAGE_TRIPLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[2].photo_url(:_320x320)}")) do |c| # C
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: 560}).add_creator_information(self.creator)

    result.format 'png'
    result
  end

  # AA AA AA BB
  # AA AA AA BB
  # A-titl-A CC
  # AA AA AA CC
  # AA AA AA DD
  # creator- DD
  def generate_four_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_TRIPLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_TRIPLE_CELL_SIZE}x#{COLLAGE_TRIPLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[2].photo_url(:_320x320)}")) do |c| # C
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[3].photo_url(:_320x320)}")) do |c| # D
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: 560}).add_creator_information(self.creator)

    result.format 'png'
    result
  end



  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title------
  # creator----
  def generate_five_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[2].photo_url(:_320x320)}")) do |c| # C
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[3].photo_url(:_320x320)}")) do |c| # D
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[4].photo_url(:_320x320)}")) do |c| # E
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: 760, max_height: 80, y: (COLLAGE_DOUBLE_CELL_SIZE+COLLAGE_PADDING+COLLAGE_PADDING)}).add_creator_information(self.creator)

    result.format 'png'
    result
  end

  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title--- FF
  # creator- FF
  def generate_six_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[2].photo_url(:_320x320)}")) do |c| # C
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[3].photo_url(:_320x320)}")) do |c| # D
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[4].photo_url(:_320x320)}")) do |c| # E
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[5].photo_url(:_320x320)}")) do |c| # F
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      y = y + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: (760 - COLLAGE_SINGLE_CELL_SIZE - COLLAGE_PADDING), max_height: 80, y: (COLLAGE_DOUBLE_CELL_SIZE+COLLAGE_PADDING+COLLAGE_PADDING)}).add_creator_information(self.creator)

    result.format 'png'
    result
  end

  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title FF GG
  # cretr FF GG
  def generate_seven_item_collage
    valid_items = valid_items()

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    result = blurred_image("#{COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_50x50)}", {max_width: 800, width: 800, max_height: 800, height: 600}).composite(MiniMagick::Image.open(COLLAGE_LOCAL_PATH+valid_items[0].photo_url(:_640x640))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[1].photo_url(:_320x320)}")) do |c| # B
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[2].photo_url(:_320x320)}")) do |c| # C
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[3].photo_url(:_320x320)}")) do |c| # D
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[4].photo_url(:_320x320)}")) do |c| # E
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[5].photo_url(:_320x320)}")) do |c| # F
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{COLLAGE_LOCAL_PATH+valid_items[6].photo_url(:_320x320)}")) do |c| # G
      c.compose 'Over'
      c.gravity COLLAGE_DEFAULT_GRAVITY
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite_title(self.title, {max_width: (760 - COLLAGE_SINGLE_CELL_SIZE - COLLAGE_PADDING), max_height: 80, y: (COLLAGE_DOUBLE_CELL_SIZE+COLLAGE_PADDING+COLLAGE_PADDING)}).add_creator_information(self.creator)

    result.format 'png'
    result
  end
end
