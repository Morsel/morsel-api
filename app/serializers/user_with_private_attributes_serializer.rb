class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :draft_count,
             :like_count,
             :morsel_count,
             :sign_in_count,
             :facebook_uid,
             :twitter_username

  def like_count
    object.morsel_likes_for_my_morsels_by_others_count
  end

  def morsel_count
    object.morsels.count
  end

  def draft_count
    object.posts.drafts.count
  end

  def facebook_uid
    FacebookUserDecorator.new(object).facebook_uid
  end

  def twitter_username
    TwitterUserDecorator.new(object).twitter_username
  end
end
