class MorselSerializer < SlimMorselSerializer
  attributes :draft,
             :total_like_count,
             :total_comment_count,
             :url,
             :facebook_mrsl,
             :twitter_mrsl

  has_one :creator, serializer: SlimUserSerializer
  has_many :items, serializer: ItemSansMorselSerializer
  has_one :place, serializer: SlimPlaceSerializer

  def items
    object.items.order(Item.arel_table[:sort_order].asc)
  end
end
