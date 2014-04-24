class CommentAuthorizer < ApplicationAuthorizer
  def deletable_by?(user)
    # Only Admin, Comment's Creator, and the Commentable's Creator can DELETE resources
    super || user.has_role?(:creator, resource.commentable)
  end
end
