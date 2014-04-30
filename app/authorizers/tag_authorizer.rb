class TagAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    if resource.kind_of?(User)
      user.has_role?(:admin) || user.has_role?(:creator, resource) || user == resource
    else
      user.has_role?(:admin) || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.taggable)
    end
  end

  def deletable_by?(user)
    user.has_role?(:admin) || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.taggable)
  end
end
