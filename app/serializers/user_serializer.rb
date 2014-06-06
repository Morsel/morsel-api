class UserSerializer < SlimUserSerializer
  include PhotoUploadableSerializerAttributes

  attributes :created_at,
             :facebook_uid,
             :twitter_username,
             :morsel_count,
             :following,
             :followed_user_count,
             :follower_count

  def facebook_uid
    FacebookAuthenticatedUserDecorator.new(object).facebook_uid
  end

  def twitter_username
    TwitterAuthenticatedUserDecorator.new(object).twitter_username
  end

  def following
    current_user.present? && current_user.following_user?(object)
  end
end
