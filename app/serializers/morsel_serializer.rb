class MorselSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :creator_id,
             :created_at,
             :photos

  def attributes
    data = super
    post = @options[:post]
    if post.present?
      data[:post_id] = post.id
      data[:sort_order] = object.sort_order_for_post_id(post.id)
      data[:url] = object.url(post)
    end

    if current_user.present?
      data[:liked] = current_user.likes?(object)
      data[:draft] = object.draft if current_user == object.creator
    end
    data
  end

  def photos
    object.photos_hash
  end
end
