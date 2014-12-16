class CollectionSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :creator_id,
             :place_id,
             :created_at,
             :updated_at,
             :slug,
             :url

  has_one :creator, serializer: SlimUserSerializer
  has_many :primary_morsels, serializer: SlimMorselSerializer
end
