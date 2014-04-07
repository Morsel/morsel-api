class PostCollageGeneratorDecorator < SimpleDelegator
  # TODO:
  #   Tests. Use somethiing like wraith to compare images in a spec to make sure result is correct: https://github.com/BBC-News/wraith/blob/master/spec/wraith_spec.rb http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  #   Cleanup, decouple, and DRY.

  COLLAGE_PADDING = 4
  COLLAGE_SINGLE_CELL_SIZE = 95
  COLLAGE_DOUBLE_CELL_SIZE = (COLLAGE_SINGLE_CELL_SIZE * 2) + COLLAGE_PADDING
  COLLAGE_TRIPLE_CELL_SIZE = COLLAGE_DOUBLE_CELL_SIZE + COLLAGE_PADDING

  def generate
    morsel_count = morsels.count
    if morsel_count == 5
      self.photo = generate_five_item_collage(self)
      save!
    elsif morsel_count == 6
      self.photo = generate_six_item_collage(self)
      save!
    elsif morsel_count >= 7
      self.photo = generate_seven_item_collage(self)
      save!
    else
      puts "Invalid Post passed: #{id} or no template exists for Post with #{morsel_count} Morsels"
    end
  end

  private

  # AA AA AA BB
  # AA AA AA BB
  # A-titl-A CC
  # AA AA AA CC
  # AA AA AA DD
  # creator- DD
  def generate_four_item_collage(post)
  end

  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title------
  # creator----
  def generate_five_item_collage(post)
    primary_morsel = post.primary_morsel
    creator = post.creator

    morsels = []
    morsels.push(primary_morsel) if primary_morsel

    post.morsels.each do |m|
      morsels.push(m) if m && m != primary_morsel
    end

    if Rails.env.development?
      local_path = "#{Rails.root}/public"
    else
      local_path = ''
    end

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    gravity = 'NorthWest'
    font = Rails.root.join('app', 'assets', 'fonts', 'RobotoCondensed-Regular.ttf')
    font_bold = Rails.root.join('app', 'assets', 'fonts', 'RobotoSlab-Bold.ttf')

    tmp = Tempfile.new(%W[mini_magick_collage_ .png])

    # -modulate brightness[,saturation,hue]
    # Vary the brightness, saturation, and hue of an image.
    # The arguments are given as a percentages of variation. A value of 100 means no change, and any missing values are taken to mean 100.
    # The brightness is a multiplier of the overall brightness of the image, so 0 means pure black, 50 is half as bright, 200 is twice as bright. To invert its meaning -negate the image before and after.
    # The saturation controls the amount of color in an image. For example, 0 produce a grayscale image, while a large value such as 200 produce a very colorful, 'cartoonish' color.
    `convert "#{local_path+morsels[0].photo_url(:_50x50)}" -gaussian-blur 20 -modulate 70,40 -resize 400x400 -extent 400x300 #{tmp.path}`

    background_image = MiniMagick::Image.new(tmp.path, tmp)

    creator_photo = MiniMagick::Image.open("#{local_path+creator.photo_url(:_144x144)}")

    result = background_image.composite(MiniMagick::Image.open(local_path+morsels[0].photo_url(:_480x480))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity gravity
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[1].photo_url(:_240x240)}")) do |c| # B
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[2].photo_url(:_240x240)}")) do |c| # C
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[3].photo_url(:_240x240)}")) do |c| # D
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[4].photo_url(:_240x240)}")) do |c| # E
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(creator_photo) do |c| # Creator Pic
      c.compose 'Over'
      c.gravity 'SouthWest'
      c.geometry '50x50+10+10'
    end

    result.combine_options do |c|
      c.font font_bold
      c.fill "white"
      c.pointsize 30
      c.gravity 'SouthWest'
      c.stroke 'black'
      c.strokewidth 3
      c.draw "text 10,65 '#{post.title}'"
      c.stroke 'none'
      c.draw "text 10,65 '#{post.title}'"

      c.strokewidth 1

      c.font font
      c.pointsize 15
      c.stroke 'black'
      c.draw "text 70, 34 '#{creator.full_name}'"
      c.stroke 'none'
      c.draw "text 70, 34 '#{creator.full_name}'"

      c.pointsize 12
      c.stroke 'black'
      c.draw "text 70, 19 'eatmorsel.com/#{creator.username}'"
      c.stroke 'none'
      c.draw "text 70, 19  'eatmorsel.com/#{creator.username}'"
    end

    result.format 'png'
    result
  end

  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title--- FF
  # creator- FF
  def generate_six_item_collage(post)
    primary_morsel = post.primary_morsel
    creator = post.creator

    morsels = []
    morsels.push(primary_morsel) if primary_morsel

    post.morsels.each do |m|
      morsels.push(m) if m && m != primary_morsel
    end

    if Rails.env.development?
      local_path = "#{Rails.root}/public"
    else
      local_path = ''
    end

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    gravity = 'NorthWest'
    font = Rails.root.join('app', 'assets', 'fonts', 'RobotoCondensed-Regular.ttf')
    font_bold = Rails.root.join('app', 'assets', 'fonts', 'RobotoSlab-Bold.ttf')

    tmp = Tempfile.new(%W[mini_magick_collage_ .png])

    # -modulate brightness[,saturation,hue]
    # Vary the brightness, saturation, and hue of an image.
    # The arguments are given as a percentages of variation. A value of 100 means no change, and any missing values are taken to mean 100.
    # The brightness is a multiplier of the overall brightness of the image, so 0 means pure black, 50 is half as bright, 200 is twice as bright. To invert its meaning -negate the image before and after.
    # The saturation controls the amount of color in an image. For example, 0 produce a grayscale image, while a large value such as 200 produce a very colorful, 'cartoonish' color.
    `convert "#{local_path+morsels[0].photo_url(:_50x50)}" -gaussian-blur 20 -modulate 70,40 -resize 400x400 -extent 400x300 #{tmp.path}`

    background_image = MiniMagick::Image.new(tmp.path, tmp)

    creator_photo = MiniMagick::Image.open("#{local_path+creator.photo_url(:_144x144)}")

    result = background_image.composite(MiniMagick::Image.open(local_path+morsels[0].photo_url(:_480x480))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity gravity
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[1].photo_url(:_240x240)}")) do |c| # B
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[2].photo_url(:_240x240)}")) do |c| # C
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[3].photo_url(:_240x240)}")) do |c| # D
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[4].photo_url(:_240x240)}")) do |c| # E
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[5].photo_url(:_240x240)}")) do |c| # F
      c.compose 'Over'
      c.gravity gravity
      y = y + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(creator_photo) do |c| # Creator Pic
      c.compose 'Over'
      c.gravity 'SouthWest'
      c.geometry '50x50+10+10'
    end

    result.combine_options do |c|
      c.font font_bold
      c.fill "white"
      c.pointsize 30
      c.gravity 'SouthWest'
      c.stroke 'black'
      c.strokewidth 3
      c.draw "text 10,65 '#{post.title}'"
      c.stroke 'none'
      c.draw "text 10,65 '#{post.title}'"

      c.strokewidth 1

      c.font font
      c.pointsize 15
      c.stroke 'black'
      c.draw "text 70, 34 '#{creator.full_name}'"
      c.stroke 'none'
      c.draw "text 70, 34 '#{creator.full_name}'"

      c.pointsize 12
      c.stroke 'black'
      c.draw "text 70, 19 'eatmorsel.com/#{creator.username}'"
      c.stroke 'none'
      c.draw "text 70, 19  'eatmorsel.com/#{creator.username}'"
    end

    result.format 'png'
    result
  end

  # AA AA BB CC
  # AA AA BB CC
  # AA AA DD EE
  # AA AA DD EE
  # title FF GG
  # cretr FF GG
  def generate_seven_item_collage(post)
    primary_morsel = post.primary_morsel
    creator = post.creator

    morsels = []
    morsels.push(primary_morsel) if primary_morsel

    post.morsels.each do |m|
      morsels.push(m) if m && m != primary_morsel
    end

    if Rails.env.development?
      local_path = "#{Rails.root}/public"
    else
      local_path = ''
    end

    x = COLLAGE_PADDING
    y = COLLAGE_PADDING

    left_offset = COLLAGE_SINGLE_CELL_SIZE + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING + COLLAGE_PADDING + COLLAGE_PADDING

    gravity = 'NorthWest'
    font = Rails.root.join('app', 'assets', 'fonts', 'RobotoCondensed-Regular.ttf')
    font_bold = Rails.root.join('app', 'assets', 'fonts', 'RobotoSlab-Bold.ttf')

    tmp = Tempfile.new(%W[mini_magick_collage_ .png])

    # -modulate brightness[,saturation,hue]
    # Vary the brightness, saturation, and hue of an image.
    # The arguments are given as a percentages of variation. A value of 100 means no change, and any missing values are taken to mean 100.
    # The brightness is a multiplier of the overall brightness of the image, so 0 means pure black, 50 is half as bright, 200 is twice as bright. To invert its meaning -negate the image before and after.
    # The saturation controls the amount of color in an image. For example, 0 produce a grayscale image, while a large value such as 200 produce a very colorful, 'cartoonish' color.
    `convert "#{local_path+morsels[0].photo_url(:_50x50)}" -gaussian-blur 20 -modulate 70,40 -resize 400x400 -extent 400x300 #{tmp.path}`

    background_image = MiniMagick::Image.new(tmp.path, tmp)

    creator_photo = MiniMagick::Image.open("#{local_path+creator.photo_url(:_144x144)}")

    result = background_image.composite(MiniMagick::Image.open(local_path+morsels[0].photo_url(:_480x480))) do |c| # A (Cover)
      c.compose 'Over'
      c.gravity gravity
      c.geometry "#{COLLAGE_DOUBLE_CELL_SIZE}x#{COLLAGE_DOUBLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[1].photo_url(:_240x240)}")) do |c| # B
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[2].photo_url(:_240x240)}")) do |c| # C
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[3].photo_url(:_240x240)}")) do |c| # D
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE + COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[4].photo_url(:_240x240)}")) do |c| # E
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[5].photo_url(:_240x240)}")) do |c| # F
      c.compose 'Over'
      c.gravity gravity
      x = left_offset
      y = y + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(MiniMagick::Image.open("#{local_path+morsels[6].photo_url(:_240x240)}")) do |c| # G
      c.compose 'Over'
      c.gravity gravity
      x = x + COLLAGE_SINGLE_CELL_SIZE+COLLAGE_PADDING
      c.geometry "#{COLLAGE_SINGLE_CELL_SIZE}x#{COLLAGE_SINGLE_CELL_SIZE}+#{x}+#{y}"
    end.composite(creator_photo) do |c| # Creator Pic
      c.compose 'Over'
      c.gravity 'SouthWest'
      c.geometry '50x50+10+10'
    end

    result.combine_options do |c|
      c.font font_bold
      c.fill "white"
      c.pointsize 30
      c.gravity 'SouthWest'
      c.stroke 'black'
      c.strokewidth 3
      c.draw "text 10,65 '#{post.title}'"
      c.stroke 'none'
      c.draw "text 10,65 '#{post.title}'"

      c.strokewidth 1

      c.font font
      c.pointsize 15
      c.stroke 'black'
      c.draw "text 70, 34 '#{creator.full_name}'"
      c.stroke 'none'
      c.draw "text 70, 34 '#{creator.full_name}'"

      c.pointsize 12
      c.stroke 'black'
      c.draw "text 70, 19 'eatmorsel.com/#{creator.username}'"
      c.stroke 'none'
      c.draw "text 70, 19  'eatmorsel.com/#{creator.username}'"
    end

    result.format 'png'
    result
  end

end
