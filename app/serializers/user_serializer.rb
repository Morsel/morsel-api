class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name,
             :created_at,
             :bio,
             :industry,
             :photos,
             :facebook_uid,
             :twitter_username,
             :morsel_count,
             :liked_items_count,
             :following,
             :followed_user_count,
             :follower_count

  def photos
    object.photos_hash
  end

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
