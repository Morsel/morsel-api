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

  has_one :creator, serializer: SlimUserSerializer
  has_one :morsel, serializer: SlimMorselSerializer

  def attributes
    hash = super
    hash['presigned_upload'] = object.presigned_upload if object.respond_to? :presigned_upload
    hash
  end

  def liked
    scope.present? && scope.likes_item?(object)
  end
end
