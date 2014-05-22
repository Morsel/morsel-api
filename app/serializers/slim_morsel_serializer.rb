class SlimMorselSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :title,
             :place_id,
             :creator_id,
             :created_at,
             :updated_at,
             :slug
end
