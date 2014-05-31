class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :staff,
             :draft_count,
             :sign_in_count,
             :photo_processing,
             :email,
             :settings

  def draft_count
    object.morsels.drafts.count
  end
end
