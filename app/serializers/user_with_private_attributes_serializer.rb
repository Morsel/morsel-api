class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :staff,
             :password_set,
             :draft_count,
             :sign_in_count,
             :photo_processing,
             :email,
             :settings

  def draft_count
    object.morsels.drafts.count
  end
end
