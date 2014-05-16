class MorselSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :title,
             :creator_id,
             :created_at,
             :updated_at,
             :published_at,
             :draft,
             :slug,
             :total_like_count,
             :total_comment_count,
             :primary_item_id,
             :url,
             :facebook_mrsl,
             :twitter_mrsl

  has_one :creator
  has_many :items

  def items
    object.items.order('sort_order ASC')
  end
end
