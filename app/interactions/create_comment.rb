class CreateComment < ActiveInteraction::Base
  model   :morsel, :user
  string  :description

  validates :morsel, presence: true
  validates :user, presence: true
  validate :user_can_create_comment?

  def execute
    comment = Comment.create(
      description: description,
      morsel: morsel,
      user: user
    )

    errors.merge!(comment.errors)

    comment
  end

  private

  def user_can_create_comment?
    errors.add(:user, 'not authorized to comment') unless user.can_create? Comment
  end
end
