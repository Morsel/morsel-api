class UserAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    # By default, only Admin or the resource (user) can UPDATE a resource (user)
    user.has_role?(:admin) || user == resource
  end
end
