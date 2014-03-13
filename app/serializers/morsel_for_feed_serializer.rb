class MorselForFeedSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :created_at,
             :updated_at,
             :nonce,
             :photos,
             :photo_processing,
             :in_progression,
             :liked,
             :creator,
             :post

  def photos
    object.photos_hash
  end

  def in_progression
    if object.posts.first
      object.posts.first.morsels.count > 1
    else
      false
    end
  end

  def liked
    current_user.present? && current_user.likes?(object)
  end

  def creator
    user = object.creator
    {
      id: user.id,
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name,
      photos: user.photos_hash
    }
  end

  def post
    post = object.posts.first
    if post
      {
        id: post.id,
        title: post.title,
        slug: post.cached_slug,
        created_at: post.created_at
      }
    else
      nil
    end
  end
end
