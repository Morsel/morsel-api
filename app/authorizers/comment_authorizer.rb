class CommentAuthorizer < ApplicationAuthorizer
  def deletable_by?(user)
    user.has_role?(:admin) || resource.user == user || resource.morsel.creator == user
  end

  def manageable_by?(user)
    user.has_role?(:admin)
  end
end
