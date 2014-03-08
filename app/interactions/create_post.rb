class CreatePost < ActiveInteraction::Base
  model   :user

  hash :params do
    string :title
    boolean :draft, default: false
  end

  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to create Post') unless user.can_create?(Post) }

  def execute
    post = Post.create(
      params.merge(
        creator: user
      )
    )

    errors.merge!(post.errors)

    post
  end
end
