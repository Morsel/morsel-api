class SlimMorselSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :title,
             :slug,
             :creator_id,
             :place_id,
             :created_at,
             :updated_at,
             :published_at,
             :primary_item_id

end
