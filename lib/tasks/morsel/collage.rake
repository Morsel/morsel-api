require 'rake'
require File.join(Rails.root, 'app', 'models', 'decorators', 'morsel_collage_generator_decorator.rb')

namespace :morsel do
  desc 'Creates a collage. Usage: morsel:collage[123]'
  task :collage, [:morsel_id] => [:environment] do |t, args|
    morsel = Morsel.find args[:morsel_id]
    if morsel
      collage_generator_decorated_morsel = MorselCollageGeneratorDecorator.new(morsel)
      collage_generator_decorated_morsel.generate
      if Rails.env.development?
        `open #{Rails.root}/public#{morsel.photo_url}`
      end
    else
      puts "Morsel ##{args[:morsel_id]} not found"
    end
  end

  # def new_image(width, height, format = "png", bgcolor = "transparent")
  #   tmp = Tempfile.new(%W[mini_magick_ .#{format}])
  #   `convert -size #{width}x#{height} xc:#{bgcolor} #{tmp.path}`
  #   MiniMagick::Image.new(tmp.path, tmp)
  # end
end
