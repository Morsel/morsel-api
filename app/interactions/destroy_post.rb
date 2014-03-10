class DestroyPost < ActiveInteraction::Base
  model   :post, :user

  validates :post, presence: true
  validates :user, presence: true
  validate :user_can_delete_post?

  def execute
    post.destroy
    errors.merge!(post.errors)
    post
  end

  private

  def user_can_delete_post?
    errors.add(:user, 'not authorized to delete post') unless user.can_delete? post
  end
end
