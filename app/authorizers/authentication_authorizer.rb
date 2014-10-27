class AuthenticationAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    resource.user == user
  end

  def updatable_by?(user)
    resource.user == user
  end

  def destroyable_by?(user)
    resource.user == user
  end
end
