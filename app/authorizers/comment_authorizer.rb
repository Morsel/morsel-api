class CommentAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # By default, anyone can CREATE resources
    user.present?
  end

  def deletable_by?(user)
    # Only Admin, Comment's Creator, or the Commentable's Creator can DELETE resources
    user.has_role?(:admin) || user.has_role?(:creator, resource) || user.has_role?(:creator, resource.commentable)
  end
end
