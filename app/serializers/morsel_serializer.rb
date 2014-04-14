class MorselSerializer < ActiveModel::Serializer
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
             :photos,
             :url,
             :facebook_mrsl,
             :twitter_mrsl

  has_one :creator

  has_many :items

  def slug
    object.cached_slug
  end

  def items
    object.items.order('sort_order ASC')
  end

  def photos
    object.photos_hash
  end
end
