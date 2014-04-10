class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :draft_count,
             :like_count,
             :item_count,
             :sign_in_count

  def like_count
    object.item_likes_for_my_items_by_others_count
  end

  def item_count
    object.items.count
  end

  def draft_count
    object.morsels.drafts.count
  end
end
