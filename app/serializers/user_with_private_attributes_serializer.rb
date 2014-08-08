class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :staff,
             :password_set,
             :draft_count,
             :sign_in_count,
             :photo_processing,
             :email,
             :settings

  def attributes
    hash = super
    hash['presigned_upload'] = object.presigned_upload if object.respond_to? :presigned_upload
    hash
  end
end
