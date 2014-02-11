class MorselSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :creator_id,
             :created_at,
             :draft,
             :photos,
             :liked

  def attributes
    data = super
    post = @options[:post]
    if post.present?
      data[:post_id] = post.id
      data[:sort_order] = object.sort_order_for_post_id(post.id)
      data[:url] = object.url(post)
    end
    data
  end

  def photos
    if object.photo_url.present?
      {
        _104x104: object.photo_url(:_104x104),
        _208x208: object.photo_url(:_208x208),
        _320x214: object.photo_url(:_320x214),
        _640x428: object.photo_url(:_640x428),
        _640x640: object.photo_url(:_640x640)
      }
    else
      nil
    end
  end

  def liked
    current_user.likes?(object)
  end
end
