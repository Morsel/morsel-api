class MorselSerializer < SlimMorselSerializer
  attributes :draft,
             :like_count,
             :url,
             :template_id,
             :facebook_mrsl,  # DEPRECATED, use mrsl[facebook_mrsl] instead
             :twitter_mrsl,   # DEPRECATED, use mrsl[twitter_mrsl] instead
             :mrsl,
             :has_tagged_users,
             :tagged,
             :liked

  has_one :creator, serializer: SlimUserSerializer
  has_many :items, serializer: ItemSansMorselSerializer
  has_one :place, serializer: SlimPlaceSerializer

  def has_tagged_users
    object.tagged_users?
  end

  def tagged
    has_tagged_users && scope.present? && object.tagged_user?(scope)
  end

  def liked
    scope.present? && scope.likes_morsel?(object)
  end
end
