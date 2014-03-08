class CreateComment < ActiveInteraction::Base
  model   :morsel, :user
  string  :description

  validates :morsel, presence: true
  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to create Comment') unless user.can_create?(Comment) }

  def execute
    comment = Comment.create(
      description: description,
      morsel: morsel,
      user: user
    )

    errors.merge!(comment.errors)

    comment
  end
end
