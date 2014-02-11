class PostSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :creator_id,
             :created_at,
             :slug

  has_one :creator

  has_many :morsels

  def slug
    object.cached_slug
  end

  def morsels
    if @options[:include_drafts]
      object.morsels
    else
      object.morsels.published
    end
  end
end
