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
             :facebook_uid,
             :twitter_username,
             :item_count,
             :like_count

  def photos
    object.photos_hash
  end

  def facebook_uid
    FacebookUserDecorator.new(object).facebook_uid
  end

  def twitter_username
    TwitterUserDecorator.new(object).twitter_username
  end

  def item_count
    object.items.count
  end
end
