class PostSerializer < ActiveModel::Serializer
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
             :primary_morsel_id

  has_one :creator

  has_many :morsels

  def slug
    object.cached_slug
  end

  def morsels
    object.morsels.order('sort_order ASC')
  end
end
