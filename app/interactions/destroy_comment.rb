class DestroyComment < ActiveInteraction::Base
  model   :comment, :user

  validates :comment, presence: true
  validates :user, presence: true
  validate :user_can_delete_comment?

  def execute
    comment.destroy
    errors.merge!(comment.errors)
  end

  private

  def user_can_delete_comment?
    errors.add(:user, 'not authorized to delete comment') unless user.can_delete? comment
  end
end
