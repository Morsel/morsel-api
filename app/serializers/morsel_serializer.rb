class MorselSerializer < SlimMorselSerializer
  attributes :draft,
             :summary,
             :like_count,
             :url,
             :template_id,
             :facebook_mrsl,    # DEPRECATED, Change: facebook_mrsl -> mrsl[facebook_mrsl] (https://app.asana.com/0/19486350215520/19486350215556)
             :twitter_mrsl,     # DEPRECATED, Change: twitter_mrsl -> mrsl[twitter_mrsl] (https://app.asana.com/0/19486350215520/19486350215558)
             :mrsl,
             :has_tagged_users, # DEPRECATED, Remove: has_tagged_users (https://app.asana.com/0/19486350215520/20107444356081)
             :tagged,
             :liked,
             :schedual_date,
             :morsel_video,
             :video_text,
             :local_schedual_date

  has_many :items, serializer: ItemSansMorselAndCreatorSerializer
  has_many :morsel_keywords, serializer: MorselKeywordSerializer
  has_many :morsel_topics, serializer: MorselTopicSerializer

  def has_tagged_users
    object.tagged_users?
  end

  def tagged
    if has_tagged_users
      scope.present? ? object.tagged_user?(scope) : nil
    else
      scope.present? ? false : nil
    end
  end

  def liked
    scope.present? ? scope.likes_morsel?(object) : nil
  end
end
