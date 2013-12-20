module PlaceholderHelper
  def placeholder_image(width, height)
    image_tag("http://placekitten.com/#{width}/#{height}", alt: "#{width}x#{height}", class: 'placeholder_image')
  end
end
