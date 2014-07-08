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
    if options[:context] && options[:context][:presigned_upload]
      hash['presigned_upload'] = options[:context][:presigned_upload]
    end
    hash
  end

  def liked
    current_user.present? && current_user.likes_item?(object)
  end
end
