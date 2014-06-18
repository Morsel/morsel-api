class TagAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    if resource.kind_of?(User)
      user.professional? || user.has_role?(:creator, resource) || user == resource
    else
      user.professional? || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.taggable)
    end
  end

  def deletable_by?(user)
    user.admin? || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.taggable)
  end
end
