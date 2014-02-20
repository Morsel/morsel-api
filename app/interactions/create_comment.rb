class CreateComment < ActiveInteraction::Base
  model   :morsel, :user
  string  :description

  validates :morsel, presence: true
  validates :user, presence: true

  def execute
    comment = Comment.create(
      description: description,
      morsel: morsel,
      user: user
    )

    comment
  end
end
