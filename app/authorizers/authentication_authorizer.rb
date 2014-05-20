class AuthenticationAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # Any User can CREATE an Authentication
    user.present?
  end

  def updatable_by?(user)
    # By default, only Admin and the resource's Creator can UPDATE Authentications
    user.has_role?(:admin) || user.has_role?(:creator, resource)
  end
end
