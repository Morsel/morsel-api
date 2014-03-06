class DestroyLike < ActiveInteraction::Base
  model   :morsel, :user

  validates :morsel, presence: true
  validates :user, presence: true
  validate :user_can_delete_like?
  validate :user_has_liked_morsel_already

  def execute
    like = Like.find_by(morsel: morsel, user: user)
    like.destroy
    errors.merge!(like.errors)
  end

  private

  def user_has_liked_morsel_already
    errors.add(:morsel, 'not liked') unless morsel.likers.include? user
  end

  def user_can_delete_like?
    like = Like.find_by(morsel: morsel, user: user)
    if like
      errors.add(:user, 'not authorized to unlike') unless user.can_delete? like
    else
      errors.add(:morsel, 'not liked')
    end
  end
end
