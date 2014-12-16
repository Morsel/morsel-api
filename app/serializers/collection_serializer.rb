class CollectionSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :user_id,
             :place_id,
             :created_at,
             :updated_at,
             :slug,
             :url

  has_many :primary_morsels, serializer: SlimMorselSerializer
end
