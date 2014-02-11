class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :like_count,
             :morsel_count,
             :sign_in_count,
             :twitter_username,
             :facebook_uid,
             :draft_count

  def like_count
    object.morsel_likes_for_my_morsels_by_others_count
  end

  def morsel_count
    object.morsels.count
  end

  def draft_count
    object.morsels.drafts.count
  end
end
