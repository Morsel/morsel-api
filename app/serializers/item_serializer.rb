class ItemSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :creator_id,
             :updated_at,
             :created_at,
             :nonce,
             :photos,
             :photo_processing,
             :sort_order,
             :url,
             :morsel_id,
             :liked,
             :like_count,
             :comment_count


  def liked
    current_user.present? && current_user.likes_item?(object)
  end

  def photos
    object.photos_hash
  end
end
