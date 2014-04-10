class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name,
             :created_at,
             :title,
             :bio,
             :industry,
             :photos,
             :photo_processing,
             :facebook_uid,
             :twitter_username

  def photos
    object.photos_hash
  end

  def facebook_uid
    FacebookUserDecorator.new(object).facebook_uid
  end

  def twitter_username
    TwitterUserDecorator.new(object).twitter_username
  end
end
