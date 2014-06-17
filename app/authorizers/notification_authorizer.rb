class NotificationAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    # Only Admin or Notification user (receiver) can update a Notification
    user.has_role?(:admin) || resource.user == current_user
  end
end
