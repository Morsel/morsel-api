class DestroyComment < ActiveInteraction::Base
  model   :comment, :user

  validates :comment, presence: true
  validates :user, presence: true
  validate :user_is_comment_or_morsel_creator

  def execute
    comment.destroy
  end

  private

  def user_is_comment_or_morsel_creator
    errors.add(:user, 'not authorized to delete comment') if comment.user != user && comment.morsel.creator != user
  end
end
