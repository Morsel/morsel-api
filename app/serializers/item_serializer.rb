class ItemSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :description,
             :creator_id,
             :updated_at,
             :created_at,
             :nonce,
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
end
