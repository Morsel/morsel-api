class UserWithLikeAndMorselCountSerializer < UserSerializer
  attributes :like_count,
             :morsel_count

  def like_count
    object.morsel_likes_for_my_morsels_by_others_count
  end

  def morsel_count
    object.morsels.count
  end
end
