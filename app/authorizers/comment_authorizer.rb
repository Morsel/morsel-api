class CommentAuthorizer < ApplicationAuthorizer
  def deletable_by?(user)
    # Only Admin, Comment's Creator, or the Commentable's Creator can DELETE resources
    user.has_role?(:admin) || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.commentable)
  end
end
