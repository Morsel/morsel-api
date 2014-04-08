class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, post_id)
    user = User.includes(:authorizations).find(user_id)
    post = Post.find post_id

    if post.photo.nil?
      collage_generator_decorated_post = PostCollageGeneratorDecorator.new(post)
      collage_generator_decorated_post.generate
    end

    case network
    when 'facebook'
      FacebookUserDecorator.new(user).post_facebook_message(post.facebook_message)
    when 'twitter'
      TwitterUserDecorator.new(user).post_twitter_message(post.twitter_message)
    else
      raise "Invalid Network: #{network}"
    end
  end
end
