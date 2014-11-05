class MorselSerializer < SlimMorselSerializer
  attributes :draft,
             :like_count,
             :url,
             :template_id,
             :facebook_mrsl,  # DEPRECATED, Change: facebook_mrsl -> mrsl[facebook_mrsl] (https://app.asana.com/0/19486350215520/19486350215556)
             :twitter_mrsl,   # DEPRECATED, Change: twitter_mrsl -> mrsl[twitter_mrsl] (https://app.asana.com/0/19486350215520/19486350215558)
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
