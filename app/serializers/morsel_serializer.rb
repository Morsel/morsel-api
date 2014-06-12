class MorselSerializer < SlimMorselSerializer
  attributes :published_at,
             :draft,
             :total_like_count,
             :total_comment_count,
             :primary_item_id,
             :url,
             :facebook_mrsl,
             :twitter_mrsl

  has_one :creator, serializer: SlimUserSerializer
  has_many :items, serializer: ItemSansMorselSerializer
  has_one :place, serializer: SlimPlaceSerializer

  def items
    object.items.order('sort_order ASC')
  end
end
