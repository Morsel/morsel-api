class ApplicationAuthorizer < Authority::Authorizer
  def self.default(adjective, user)
    user.has_role? :admin
  end

  def updatable_by?(user)
    user.has_role?(:admin) || resource.creator == user
  end

  def deletable_by?(user)
    user.has_role?(:admin) || resource.creator == user
  end
end
