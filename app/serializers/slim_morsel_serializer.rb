class SlimMorselSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :title,
             :slug,
             :creator_id,
             :place_id,
             :created_at,
             :updated_at,
             :draft,
             :publishing,
             :published_at,
             :primary_item_id,
             :primary_item_photos,
             :tagged_users_count

  has_one :creator, serializer: SlimUserSerializer
  has_one :place, serializer: SlimPlaceSerializer

  def attributes
    hash = super
    hash['rank'] = object.pg_search_rank if object.respond_to? :pg_search_rank
    hash
  end
end
