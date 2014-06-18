class UserAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    # By default, only Admin or the resource (user) can UPDATE a resource (user)
    user.admin? || user == resource
  end
end
