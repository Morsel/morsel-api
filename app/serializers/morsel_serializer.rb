class MorselSerializer < SlimMorselSerializer
  attributes :draft,
             :total_like_count,
             :total_comment_count,
             :url,
             :template_id,
             :facebook_mrsl,  # DEPRECATED, use mrsl[facebook_mrsl] instead
             :twitter_mrsl,   # DEPRECATED, use mrsl[twitter_mrsl] instead
             :mrsl,
             :has_tagged_users

  has_one :creator, serializer: SlimUserSerializer
  has_many :items, serializer: ItemSansMorselSerializer
  has_one :place, serializer: SlimPlaceSerializer

  def has_tagged_users
    object.tagged_users?
  end
end
