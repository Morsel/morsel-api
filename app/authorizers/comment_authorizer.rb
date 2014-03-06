class CommentAuthorizer < ApplicationAuthorizer
  def deletable_by?(user)
    # Only Admin, Comment's Creator, and the Comment's Morsel's Creator can DELETE resources
    super || user.has_role?(:creator, resource.morsel)
  end
end
