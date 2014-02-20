class DestroyLike < ActiveInteraction::Base
  model   :morsel, :user

  validates :morsel, presence: true
  validates :user, presence: true
  validate :user_has_liked_morsel_already

  def execute
    morsel.likers.destroy(user)
  end

  private

  def user_has_liked_morsel_already
    errors.add(:morsel, 'not liked') unless morsel.likers.include? user
  end
end
