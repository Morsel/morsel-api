require 'rake'
require File.join(Rails.root, 'app', 'models', 'decorators', 'post_collage_generator_decorator.rb')

namespace :morsel do
  desc 'Creates a collage. Usage: morsel:collage[123]'
  task :collage, [:post_id] => [:environment] do |t, args|
    post = Post.find args[:post_id]
    if post
      collage_generator_decorated_post = PostCollageGeneratorDecorator.new(post)
      collage_generator_decorated_post.generate
      if Rails.env.development?
        `open #{Rails.root}/public#{post.photo_url}`
      end
    else
      puts "Post ##{args[:post_id]} not found"
    end
  end

  # def new_image(width, height, format = "png", bgcolor = "transparent")
  #   tmp = Tempfile.new(%W[mini_magick_ .#{format}])
  #   `convert -size #{width}x#{height} xc:#{bgcolor} #{tmp.path}`
  #   MiniMagick::Image.new(tmp.path, tmp)
  # end
end
