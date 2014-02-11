class UserWithAuthTokenSerializer < UserWithPrivateAttributesSerializer
  attributes :auth_token

  def auth_token
    object.authentication_token
  end
end
