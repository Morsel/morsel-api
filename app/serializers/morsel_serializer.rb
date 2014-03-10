class MorselSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :creator_id,
             :updated_at,
             :created_at,
             :nonce,
             :photos,
             :photo_processing

  def attributes
    data = super
    # HACK: Eventually when we/if we do many-to-many Morsel/Posts, this will screw things up.
    post = object.posts.last
    if post.present?
      data[:post_id] = post.id
      data[:sort_order] = object.sort_order_for_post_id(post.id)
      data[:url] = object.url(post)
    end

    data[:liked] = current_user.likes?(object) if current_user.present?

    data
  end

  def photos
    object.photos_hash
  end
end
