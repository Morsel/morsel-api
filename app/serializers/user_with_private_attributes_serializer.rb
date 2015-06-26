class UserWithPrivateAttributesSerializer < UserSerializer
  attributes :staff,
             :password_set,
             :draft_count,
             :sign_in_count,
             :photo_processing,
             :email,
             :settings,
             :profile

  def attributes
    hash = super
    hash['presigned_upload'] = object.presigned_upload if object.respond_to? :presigned_upload
    hash
  end

  def profile
    object.profile.blank? ? {} : {id: object.profile.id,host_url: object.profile.host_url,host_logo: object.profile.host_logo, address:object.profile.address}
  end
end
